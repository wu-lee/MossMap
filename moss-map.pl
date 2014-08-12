#!/usr/bin/perl
# This is a Mojolicious web app for accessing and managing the moss
# map.  Much of the map is javascript driven, so doesn't need much
# server-side dynamism, but some things, like uploading and managing
# data-sets, do need some dynamism.
use v5.10;
use Mojolicious::Lite;
use Mojolicious::Plugin::Authentication;
use MossMap::Model;

use IO::String;
use Scalar::Util 'looks_like_number';

# A package variable, to make over-riding in tests easier.
our $config = plugin 'JSONConfig';

if (my $logfile = $config->{log}{file}) {
    $logfile = File::Spec->rel2abs($logfile, app->home);
    my $loglevel = $config->{log}{level} || 'warn';
    app->log( Mojo::Log->new( path => $logfile, 
                              level => $loglevel ) );
}

if (my $secret = $config->{secret}) {
    app->secret($secret);
}

plugin authentication => {
    session_key => 'moss-map',
    load_user => sub {
        my ($app, $uid) = @_;
        return $config->{users}{$uid};
    },
    validate_user => sub {
        my ($app, $username, $password) = @_;
        return $username
            if $config->{users}{$username}
            && $config->{users}{$username}{password} eq $password;
        return undef;
    },
};

my $db_path = $ENV{MOSSMAP_DB} || app->home->rel_file('db/moss-map.db');
my $model = MossMap::Model->new($db_path);
helper model => sub {
    my $self = shift;

    return $model;
};


helper get_upload_source =>  sub {
    my $self = shift;
    my $upload_param = shift;

    if ($self->req->is_limit_exceeded) {
        $self->render(
            json => {message => 
                         "File is bigger than the limit ".
                             "($ENV{MOJO_MAX_MESSAGE_SIZE}"},
            status => 413,
        );
        return;
    }

    if (!$upload_param) { 
        $self->render(
            json => {
                message => "Expected '".
                    $upload_param->name.
                        "' file field is missing." 
            },
            status => 400,
        );
        return;
    }

    my $source;
    if ($upload_param->asset->isa('Mojo::Upload::File')) {
        $upload_param->asset->cleanup(1);
        $source = $upload_param->handle;
    }
    else {
        $source = IO::String->new($upload_param->asset->slurp);
    }
    return $source;
};

helper csv_upload_wrapper => sub {
    my $self = shift;
    my $method = shift;

    my $upload = $self->param('upload');
    return unless
        my $source = $self->get_upload_source($upload);

    # Process uploaded file
    my $filename = $upload->filename;
    my $name = $self->param('name')
        // $filename;

    eval {
        app->log->debug("Processing '$filename' using $method");

        my ($id, $logs) = $self->model->$method($name, $source);

        app->log->debug("Finished processing '$filename', assigned id $id");

        $self->render(
            json => {message => "ok", id => $id, csv_messages => $logs},
            status => 201,
        );
        1;
    }
        or do {
            my $err = $@;
            app->log->debug("Error processing '$filename': $err");
            $err =~ s/ at .*//;
            return $self->render(
                json => {message => $err},
                status => 400,
            );
        };
};



# A convenience when running stand-alone
get '/' => sub { shift->redirect_to('/index.html') };


# Using the 'pub' prefix is mainly to make them proxy-passable as a
# group.
group {
    under '/session';

    get '/' => sub {
        my $self = shift;
        
        my $session = $self->session->{'moss-map'};
        my $data = $session? {username => $session} : {};
        $self->render(json => $data,
                      status => 200);
    };

    post '/login' => sub {
        my $self = shift;
        my $data = $self->req->json;
        my ($username, $password) = @$data{'username', 'password'};
        if ($self->authenticate($username,
                                $password)) {
            $self->render(json => {message => 'logged in', 
                                   username => $username});
        }
        else {
            $self->render(json => {error => 'authentication failed',
                                   username => $username},
                          status => 401);
        }
    };

    post '/logout' => sub {
        my $self = shift;

        my $session = $self->session->{'moss-map'};
        my $data = defined $session?
            {username => $session} : {};
        $data->{message} = 'logged out';
        
        $self->logout;
        $self->render(json => $data,
                      status => 200),
    };

    any '/unauthorized' => sub {
        my $self = shift;
        $self->respond_to(
            any => {status => 401,
                    text => "Log in via <a href='/pub/login.html'>/pub/login.html</a>"},
            json => {status => 401,
                     json => {error => "Unauthorized"}},
        );
    };

};




group {

    under '/data' => sub {
        my $self = shift;
        # GET requests require no authentication
        return 1 if $self->req->method eq 'GET';
        return 1 if $self->req->url->path =~ m{^/data/login(:?\..+)?$};

        # Otherwise, insist on it, sending a 401 Unauthorized
        # otherwise

        return 1 if $self->is_user_authenticated;

        $self->render(json  => {error => "Unauthorized"},
                      status => 401);
        return;
    };


    # FIXME error handling?
    # fixme return 20x statuses?

    # get an index of all sets
    get '/sets' => sub {
        my $self = shift;
        $self->respond_to(
            any => {json => $self->model->data_sets_index,
                    status => 200},
        );
    };
    
    # create a data set
    # FIXME csv version required
    post '/sets' => sub {
        my $self = shift;
        my $data = $self->req->json;
        # force creation rather than modification of any existing set
        delete $data->{id}; 
        my $id = $self->model->new_data_set($data);

        $self->respond_to(
            any => {json => {message => "ok", id => $id},
                    status => 201},
        );
    };

    # query a data set
    # FIXME csv version required
    get '/sets/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = looks_like_number($id)?
            $self->model->get_data_set($id) :
            $self->model->get_current_data_set($id);
        if ($data) {
            $self->respond_to(
                any => {json => $data,
                        status => 200},
            );
            return;
        }

        $self->respond_to(
            any => {json => {error => 'Invalid name or id', id => $id},
                    status => 404},
        );
    };

    # alter data set
    # FIXME csv version required
    put '/sets/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = $self->req->json;
        $data->{id} = $id;
        $self->model->set_data_set($data);
        $self->respond_to(
            any => {json => {message => "ok", id => $id},
                    status => 200},
        );
    };

    # remove a data set
    del 'sets/:id' => sub {
        # remove set
        my $self = shift;
        my $id = $self->param('id');
        $self->model->delete_data_set($id);
        $self->respond_to(
            any => {json => {message => "ok", id => $id},
                    status => 200},
        );
    };


    # get an index of all completion sets
    get '/completed' => sub {
        my $self = shift;
        $self->respond_to(
            any => {json => $self->model->completed_sets_index,
                    status => 200},
        );
    };

    # create a completed tetrad set
    post '/completed' => sub {
        my $self = shift;
        my $data = $self->req->json;
        # force creation rather than modification of any existing set
        delete $data->{id}; 
        my $id = $self->model->new_completed_set($data);

        $self->respond_to(
            any => {json => {message => "ok", id => $id},
                    status => 201},
        );
    };

    # query a completed tetrad set
    get '/completed/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = looks_like_number($id)?
            $self->model->get_completed_set($id) :
            $self->model->get_current_completed_set($id);
        if ($data) {
            $self->respond_to(
                any => {json => $data,
                        status => 200},
            );
            return;
        }

        $self->respond_to(
            any => {json => {error => 'Invalid name or id', id => $id},
                    status => 404},
        );
    };

    # alter completed tetrad set
    put '/completed/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = $self->req->json;
        $data->{id} = $id;
        $self->model->set_completed_set($data);
        $self->respond_to(
            any => {json => {message => "ok", id => $id},
                    status => 200},
        );
    };

    # remove a completed tetrad set
    del 'completed/:id' => sub {
        # remove set
        my $self = shift;
        my $id = $self->param('id');
        $self->model->delete_completed_set($id);
        $self->respond_to(
            any => {json => {message => "ok", id => $id},
                    status => 200},
        );
    };


};


group {

    under '/bulk' => sub {
        my $self = shift;
        # GET requests require no authentication
        return 1 if $self->req->method eq 'GET';

        # Otherwise, insist on it, sending a 401 Unauthorized
        # otherwise

        return 1 if $self->is_user_authenticated;

        $self->render(json  => {error => "Unauthorized"},
                      status => 401);
        return;
    };


    # Create a data set
    post '/sets.csv' => sub {
        my $self = shift;

        $self->csv_upload_wrapper('new_csv_data_set');
    };

    # Create a completed data set
    post '/completed.csv' => sub {
        my $self = shift;

        $self->csv_upload_wrapper('new_csv_completion_set');
    };

    # query a data set
    get '/sets/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = $self->model->get_bulk_data_set($id);
        if ($data) {
            $self->respond_to(
                any => {json => $data,
                        status => 200},
            );
            return;
        }

        $self->respond_to(
            any => {json => {error => 'Invalid id', id => $id},
                    status => 404},
        );
    };

    # query a data set
    get '/completed/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = $self->model->get_bulk_completion_set($id);
        if ($data) {
            $self->respond_to(
                any => {json => $data,
                        status => 200},
            );
            return;
        }

        $self->respond_to(
            any => {json => {error => 'Invalid id', id => $id},
                    status => 404},
        );
    };


    # get the latest set / completed set with a given name
    get '/latest/:name' => sub {
        my $self = shift;
        my $name = $self->param('name');  
        my $data = $self->model->get_bulk_latest($name);
        if ($data) {
            $self->respond_to(
                any => {json => $data,
                        status => 200},
            );
            return;
        }

        $self->respond_to(
            any => {json => {error => 'Invalid name', name => $name},
                    status => 404},
        );
    };

};


%Test::Mojo:: or app->start;


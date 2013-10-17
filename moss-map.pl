#!/usr/bin/perl
# This is a Mojolicious web app for accessing and managing the moss
# map.  Much of the map is javascript driven, so doesn't need much
# server-side dynamism, but some things, like uploading and managing
# data-sets, do need some dynamism.
use Mojolicious::Lite;
use Mojolicious::Plugin::Authentication;
use MossMap::Model;

use IO::String;

my %users = (
    user1 => {password => 'secret'},
);

plugin authentication => {
    session_key => 'moss-map',
    load_user => sub {
        my ($app, $uid) = @_;
        return $users{$uid};
    },
    validate_user => sub {
        my ($app, $username, $password) = @_;
        return $username
            if $users{$username}
            && $users{$username}{password} eq $password;
        return undef;
    },
};

my $db_path = $ENV{MOSSMAP_DB} || app->home->rel_file('db/moss-map.db');
my $model = MossMap::Model->new($db_path);
helper model => sub {
    my $self = shift;

    return $model;
};

# A convenience when running stand-alone
get '/' => sub { shift->redirect_to('/index.html') };

group {

    under '/data' => sub {
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
    get '/set/:id' => sub {
        my $self = shift;
        my $id = $self->param('id');  
        my $data = $self->model->get_data_set($id);
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

    # alter data set
    # FIXME csv version required
    put '/set/:id' => sub {
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
    del 'set/:id' => sub {
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
    get '/completions' => sub {
        my $self = shift;
        $self->respond_to(
            any => {json => $self->model->completion_sets_index,
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


    # FIXME error handling?
    # fixme return 20x statuses?

    # create a data set
    post '/sets.csv' => sub {
        my $self = shift;

        # Check file size
        return $self->render(
            json => {message => 
                         "File is bigger than the limit ".
                             "($ENV{MOJO_MAX_MESSAGE_SIZE}"},
            status => 413,
        )
            if $self->req->is_limit_exceeded;
        
        # Process uploaded file
        return $self->render(
            json => {message => "Expected 'upload' file field is missing."},
            status => 400,
        )
            unless my $upload = $self->param('upload');

        my $source;
        if($upload->asset->isa('Mojo::Upload::File')) {
            $upload->asset->cleanup(1);
            $source = $upload->handle;
        }
        else {
            $source = IO::String->new($upload->asset->slurp);
        }

        eval {
            my ($id, $logs) = $self->model->new_csv_data_set($upload->filename, $source);
            $self->render(
                json => {message => "ok", id => $id, csv_messages => $logs},
                status => 201,
            );
            1;
        }
            or do {
                my $err = $@;
                
                return $self->render(
                    json => {message => $err},
                    status => 400,
                );
            };
    };

    # Add completed data
    post '/completed.csv' => sub {
        my $self = shift;

        # Check file size
        return $self->render(
            json => {message => 
                         "File is bigger than the limit ".
                             "($ENV{MOJO_MAX_MESSAGE_SIZE}"},
            status => 413,
        )
            if $self->req->is_limit_exceeded;
        
        # Process uploaded file
        return $self->render(
            json => {message => "Expected 'upload' file field is missing."},
            status => 400,
        )
            unless my $upload = $self->param('upload');

        my $source;
        if($upload->asset->isa('Mojo::Upload::File')) {
            $upload->asset->cleanup(1);
            $source = $upload->handle;
        }
        else {
            $source = IO::String->new($upload->asset->slurp);
        }

        eval {
            my ($id, $log) = $self->model->new_csv_completion_set($upload->filename, $source);
            $self->render(
                json => {message => "ok", id => $id, csv_messages => $log},
                status => 201,
            );
            1;
        }
            or do {
                my $err = $@;
        
                return $self->render(
                    json => {message => $err},
                    status => 400,
                );
            };
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

__DATA__



__END__

static stuff gets served as is,

index.html -> index.html, etc.

dynamic API:

# set/taxon/gridref/date/who
GET  data/set - show uploaded data sets
GET  data/set/:setid - show uploaded data set
GET  data/set/:setid/:taxon - show taxon data
GET  data/set/:setid/:taxon/:gridref - show taxon data
GET  data/set/:setid/:taxon/:gridref/:date - show taxon data
GET  data/set/:setid/:taxon/:gridref/:date/:index - show taxon data

PUT data/set/:setid - create/modify data
PUT data/set/:setid/... - modify data

DELETE data/set/:setid - delete data
DELETE data/set/:setid/... - delete data


GET login
POST login
POST logout



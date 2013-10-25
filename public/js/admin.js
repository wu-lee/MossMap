'use strict';

angular.module('AdminModule', ['ui.bootstrap', 'ngGrid', 'ngResource']);

angular.module('AdminModule')
    .factory('session', function($http) {
        var session = {};
        
        function checkSession() {
            $http.get('/session')
                .then(function(p) { 
                    if (p.data && p.data.username) {
                        session.username = p.data.username;
                        session.active = true;
                    }
                    else {
                        session.active = false;
                        session.username = '';
                    }
                    delete session.error;
                    // FIXME check status
                });
        };
        
        session.check = checkSession;

        return session;
    });

angular.module('AdminModule')
    .controller('UploadController', function($scope, $modal, $http, $window, $document, $resource, session) {

        $scope.setName = "cheshire";
        $scope.session = session;

        session.check();

        // Check for the various File API support.
        if (!$window.File 
         || !$window.FileReader
         || !$window.FileList
         || !$window.Blob) {
            $window.alert('The File APIs are not fully supported in this browser.');
            return;
        }


        var DataSet = $resource(
            '/data/sets/:setId',
            {setId: '@id'});

        $scope.dataSets = DataSet.query();

        var CompletionSet = $resource(
            '/data/completions/:setId',
            {setId: '@id'});

        $scope.completionSets = CompletionSet.query();
   

        $scope.uploadStatus;
        $scope.uploadFile = function(input_selector) {
            var fileInput = angular.element(input_selector);
            
            var file = fileInput.get(0).files[0];
            
            console.log("upload");
            var reader = new FileReader();
            
            // Set the handler
            reader.onload = function() {
                console.log("onload ");
                var fd = new FormData();
                fd.append("upload", file);
                console.log("onload file set");
                fd.append("name", $scope.setName);
                console.log("onload name set");
                $scope.uploadStatus = "Uploading...";
                var promise = $http.post(
                    "/bulk/sets.csv",
                    fd, 
                    {   // This part is important, it allows multi-part type
                        // to be set by angularjs
                        headers: {'Content-Type': undefined },
                        transformRequest: angular.identity
                    }
                );
                promise
                    .success(function(d) {
                        $scope.uploadStatus = "Done: "+d.message;
                    })
                    .error(function(d) {
                        $scope.uploadStatus = "Error: "+d;
                    });

                // sometimes angular doesn't start uploading first
                // click, unless we give it a prod...
                $scope.$apply();  
            };
            
            // Read in the image file as a data URL.
            reader.readAsBinaryString(file);
        };
   
    $scope.loginDialog = function() {
        var modalInstance = $modal.open({
            templateUrl: '_login.html',
            controller: 'LoginController',
        });
    };

    $scope.logoutDialog = function() {
        var modalInstance = $modal.open({
            templateUrl: '_logout.html',
            controller: 'LogoutController',
        });
    };

     
});


angular.module('AdminModule')
    .controller('LoginController', function($scope, $http, $modalInstance, session) {
        // We use a reference to an object containing the credentials
        // since the login form's $scope will be a child of this one.
        var credentials = $scope.credentials = {
            username: session.username,
            password: '',
        };
        $scope.ok = function() {
            $http.post('/session/login',
                       { username: credentials.username, 
                         password: credentials.password })
                .then(function(p) { 
                    if (p.data && p.data.username) {
                        session.username = p.data.username;
                        session.active = true;
                        delete session.error;
                    }
                    else {
                        session.active = false;
                        session.error = p.data.error;
                    }
                    credentials.password = '';
                    // FIXME check status
                },
                      function(p){ 
                          session.error = 
                              p? p.data? p.data.error : 'failed' : 'failed';
                          
                      });

            $modalInstance.close();
        };

        $scope.cancel = function() { $modalInstance.close() };
    });

angular.module('AdminModule')
    .controller('LogoutController', function($scope, $http, $modalInstance, session) {
        
        $scope.ok = function() {
            $http.post('/session/logout', {})
                .then(function() {
                    session.password = '';
                    session.check();
                });
        
            $modalInstance.close();
        };

        $scope.cancel = function() { $modalInstance.close() };
    });


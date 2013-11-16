'use strict';

angular.module('DataBrowserModule', ['ui.bootstrap', 'ngGrid', 'ngResource']);

angular.module('DataBrowserModule')
    .config(function($routeProvider) {
        $routeProvider
            .when('/observations', {
                templateUrl: '_data-grid.html',
                controller: 'ObservationsController'
            })
            .when('/completed-tetrads', {
                templateUrl: '_data-grid.html',
                controller: 'CompletedTetradsController'
            })
            .otherwise({
                redirectTo: '/observations'
            });
    });


angular.module('DataBrowserModule')
    .directive('input', function() {
        return {
            restrict: 'EA',
            require: '?ngModel',
            link: function (scope, element, attr, ngModel) {
                if (attr.type !== 'file') return;

                if (!ngModel) return;

                // We don't fully implement $render since we have no
                // easy way to set the file(s) to anything.  All we do
                // is reset the input.
                var rawElement = element.get(0);
                ngModel.$render = function() {
                    rawElement.reset && rawElement.reset();
                };

                // On a change of files, update the model
                element.bind('change', function(event){
                    var files = rawElement.files;
                    var fileName = files.length > 0? files[0].name : '';
                    ngModel.$setViewValue(fileName);
                    scope.$apply();
                });
            }
        };
    });

angular.module('DataBrowserModule')
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

angular.module('DataBrowserModule')
    .controller('DataViewController', function($scope, $window, $modal, $location, session) {

        $scope.session = session;

        session.check();

        // Check for the various File API support.
        if (!$window.File 
         || !$window.FileReader
         || !$window.FileList
         || !$window.Blob) {
            $window.alert('The File APIs are not fully supported in this '+
                          'browser.  You will not be able to upload data.');
            return;
        }


        $scope.regionName = 'cheshire';
        $scope.regions = [
            { name: 'cheshire' }
        ];
        
        $scope.path = function() {
            return $location.path();
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

        $scope.uploadDialog = function() {
            var modalInstance = $modal.open({
                templateUrl: '_upload.html',
                controller: 'UploadController',
                scope: this,
            });
        };

        // FIXME make this a service
        function reloadData() {
            var myScope = this;
            var resource = myScope.resource;
            var id = myScope.regionName;
            var transform = myScope.resourceTransform;

            myScope.message = "Loading data, please wait..."; 
            var loadingDialog = $modal.open({
                templateUrl: '_loading.html',
                scope: myScope,
            });

            var promise = loadingDialog.opened.then(function() {
                myScope.data = resource.get(
                    {setId: id},
                    function() {
                        if (transform) {
                            var d = myScope.data.records;
                            for(var ix = 0; ix < d.length; ++ix) {
                                transform(d[ix]);
                            }
                        }
                        loadingDialog.close();
                    },
                    function(err) {
                        myScope.message = "Loading failed.";
                        myScope.details = "Server returned error code "+
                            err.status+", reason: "+err.data.error+
                            ", '"+id+"'";
                    }
                );
            });

            return promise;
        };

        $scope.reloadData = reloadData;
    });


angular.module('DataBrowserModule')
    .controller('ObservationsController', function($scope, $resource, $templateCache) {

        $scope.dataType = 'Observations';
        $scope.uploadUrl = '/bulk/sets.csv';

        $scope.uploadHelp = '_observationUploadHelp.html';

        $scope.resource = $resource(
            '/data/sets/:setId',
            {setId: '@id'}
        );

        $scope.resourceTransform = function(item) {
            var rr = item.recorder_records;
            delete item.recorder_records;
            var recorders = rr.map(function(it) {
                return it.recorder.name;
            });
            
            item.recorders = recorders.sort().join('; ');
        };

        $scope.gridOptions = {
            showFooter: true,
            footerTemplate:  $templateCache.get('_footer.html'),
            footerRowHeight: 40,
            data: 'data.records',
            columnDefs: 'columnDefs',
            showGroupPanel: true,
        };


        $scope.columnDefs = [
            {field: 'id', width: 100},
            {field: 'grid_ref', displayName: 'Grid Ref', width: 100},
            {field: 'taxon.name', displayName: 'Taxon'},
            {field: 'recorders', displayName: 'Recorder'},
        ];

        $scope.reloadData();
    });

angular.module('DataBrowserModule')
    .controller('CompletedTetradsController', function($scope, $resource, $templateCache) {

        $scope.dataType = 'Completed Tetrads';
        $scope.uploadUrl = '/bulk/completed.csv';

        $scope.resource = $resource(
            '/data/completed/:setId',
            {setId: '@id'}
        );
        
        $scope.gridOptions = {
            showFooter: true,
            footerTemplate:  $templateCache.get('_footer.html'),
            footerRowHeight: 40,
            data: 'data.completed_tetrads',
            columnDefs: 'columnDefs',
            showGroupPanel: false,
        };


        $scope.columnDefs = [
            {field: 'grid_ref', displayName: 'Grid Ref', width: 100},
        ];
 
        $scope.reloadData();
    });


angular.module('DataBrowserModule')
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
                    $scope.$close("Logged in successfully");
                },
                      function(p){ 
                          session.error = 
                              p? p.data? p.data.error : 'failed' : 'failed';
                          $scope.close("Log in failed");
                      });
        };
    });

angular.module('DataBrowserModule')
    .controller('LogoutController', function($scope, $http, session) {
        $scope.ok = function() {
            $http.post('/session/logout', {})
                .then(function() {
                    session.password = '';
                    session.check();
                    $scope.$close("Logged out");
                },
                      function(err) {
                          $scope.$close("Log out failed: "+err);
                      });

        };
    });


angular.module('DataBrowserModule')
    .controller('UploadController', function($scope, $http, $log) {

        $scope.uploadPercent = 0;

        $scope.regionName = 'cheshire'; // FIXME

        // A hack to work around angular's lack of support for the file input
        $scope.uploadInput = function() {
            return document.forms.uploadForm.elements.upload;
        };

        // FIXME disable upload form whilst uploading.
        // Tell user to wait...

        $scope.uploadFile = function(inputSelector) {
            var formScope = this; 
            // (Assumes we're invoked by form's ng-submit/click)

            var fileInput = angular.element(inputSelector);
            
            var node = fileInput.get(0);
            if (!node.files.length)
                return;

            var file = node.files[0];
            
            console.log("upload");
            var reader = new FileReader();
            
            // Set the handler
            reader.onload = function() {
                console.log("onload ");
                var fd = new FormData();
                fd.append("upload", file);
                fd.append("name", $scope.regionName);
                $scope.uploading = true;
                $scope.uploadPercent = 100;
                $scope.uploadMessage = "Uploading...";
                var promise = $http.post(
                    $scope.uploadUrl,
                    fd, 
                    {   // This part is important, it allows multi-part type
                        // to be set by angularjs
                        headers: {'Content-Type': undefined },
                        transformRequest: angular.identity
                    }
                );
                promise
                    .then(
                        function(success) {
                            $scope.uploadMessage = "Done!";
                            $scope.uploading = false;
                            $scope.uploadFilename = '';
                        },
                        function(resp) {
                            $log.debug("Upload error: ", resp);
                            var data = resp.data;
                            var message = 'message' in data?
                                data.message : data;
                            $scope.uploadMessage = "Error: "+message;
                            $scope.uploading = false;
                        }
                    )
                    .then(
                        function(success) {
                            $scope.reloadData();
                        }
                    );

                // sometimes angular doesn't start uploading first
                // click, unless we give it a prod...
                $scope.$apply();  
            };
            
            // Read in the image file as a data URL.
            reader.readAsBinaryString(file);
        };
    });
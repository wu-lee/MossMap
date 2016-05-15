(function() {

//'use strict';

    angular.module('DataBrowserModule', ['ui.bootstrap', 'ngRoute', 'ui.grid', 'ngResource', 'CornerCouch']);
angular.module('DataBrowserModule')
    .config(function($routeProvider) {
        $routeProvider
            .when('/observations', {
                templateUrl: 'p/data-grid.html',
                controller: 'ObservationsController'
            })
            .when('/completed-tetrads', {
                templateUrl: 'p/data-grid.html',
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
                    return rawElement.reset && rawElement.reset();
                };

                // On a change of files, update the model
                element.bind('change', function(){
                    var files = rawElement.files;
                    var fileName = files.length > 0? files[0].name : '';
                    ngModel.$setViewValue(fileName);
                    scope.$apply();
                });
            }
        };
    });

angular.module('DataBrowserModule')
    .factory('session', function(cornercouch, $rootScope, $log) {
        function logIn(user, pass) {
            session.promise = server.login(user, pass)
                .then(onSuccess, onFailure("failed to log in"));
            return session.promise;
        }

        function logOut() {
            session.promise = server.logout()
                .then(onSuccess, onFailure("failed to log out"));
            return session.promise;
        }
        
        function onSuccess(response) {
            session.name = server.userCtx.name;
            session.promise = null;
            session.roles = server.userCtx.roles;

            // Determine if we were logged in or not - the name must be set.
            if (session.name) {
                $log.info("session.loggedIn",session.name);
                $rootScope.$broadcast('session.loggedIn');
            }
            else {
                $log.info("session.loggedOut",session.name);
                $rootScope.$broadcast('session.loggedOut');
            }
            return response;
        }

        function onFailure(message) {

            return function(response) {
                // This means something broke
                
                session.name = null;
                session.promise = null;
                session.roles = [];
                session.error = {
                    reason: message,
                    response: response,
                };
                
                $rootScope.$broadcast('session.loggedOut');
                return response;
            };
        }

        function refresh() {
            return server.session()
                .then(onSuccess, onFailure);
        }

        function hasRole(role) {
            return session.roles && session.roles.indexOf(role) >= 0;
        }

        var server = cornercouch();

        var session = {
            name: null,
            refresh: refresh,
            promise: refresh(),
            logIn: logIn,
            logOut: logOut,
            roles: [],
            hasRole: hasRole,
        };

        return session;
    });


angular.module('DataBrowserModule')
        .controller('DataViewController', function($scope, $window, $uibModal, $location, session, $log) {

        $scope.session = session;

        // Check for the various File API support.
        if (!$window.File ||
            !$window.FileReader ||
            !$window.FileList ||
            !$window.Blob) {
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
            var dialog;

            function dialogOk(data) {
                dialog = null; // clear this
                // session should update automatically due to actions in LoginCtrl
            }

            function dialogDismiss() {
                dialog = null; // clear this
            }
            
            dialog = $uibModal.open({
                templateUrl: 'p/login.html',
                controller: 'LoginController',
                size: 'sm',
            });
            
            dialog.result.then(dialogOk, dialogDismiss);
        };

        $scope.logoutDialog = function() {
            $uibModal.open({
                templateUrl: 'p/logout.html',
                controller: 'LogoutController',
            });
        };

        $scope.uploadDialog = function() {
            $uibModal.open({
                templateUrl: 'p/upload.html',
                controller: 'UploadController',
                scope: this,
            });
        };

        // FIXME make this a service
        function reloadData() {
            var myScope = this;
            var resource = myScope.resource;
            var id = '0';// FIXME myScope.regionName;
            var transform = myScope.resourceTransform;

            myScope.message = "Loading data, please wait..."; 
            myScope.setId = id;
            var loadingDialog = $uibModal.open({
                templateUrl: 'p/loading.html',
                scope: myScope,
            });

            var promise = loadingDialog.opened.then(function() {
                myScope.data = resource.get(
                    {setId: id},
                    function() {
                        if (transform) {
                            var d = myScope.data.rows;
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
        }

        $scope.reloadData = reloadData;
    });


angular.module('DataBrowserModule')
    .controller('ObservationsController', function($scope, $resource, $templateCache) {

        $scope.dataType = 'Observations';
        $scope.uploadUrl = '/bulk/sets.csv';

        $scope.uploadHelp = 'p/observationUploadHelp.html';

        $scope.resource = $resource(
            '/mossmap/_design/mossmap/_view/records?startkey=["set=:setId"]&endkey=["set=:setId",{}]&include_docs=true',
            {setId: '@id'}
        );
        
        // How to munge the data items from the view
        $scope.resourceTransform = function(item) {
            // Convert the date field to a date object
            var ymd = item.key[3];
            var y = ymd.substr(0,4);
            var m = ymd.substr(4,2);
            var d = ymd.substr(6,2);
            item.key[3] = new Date(y,m,d);
        };

        $scope.gridOptions = {
            showGridFooter: true,
            enableHorizontalScrollbar: 0,
            enableFiltering: true,

            gridFooterTemplate:  $templateCache.get('footer.html'),
//            footerRowHeight: 40,
            data: 'data.rows',
            columnDefs: [
                {field: 'id', width: 100},
                {field: 'key[2]', name: 'Grid Ref', width: 100},
                {field: 'key[1]', name: 'Taxon'},
                {field: 'key[3]', name: 'Recorded On', cellFilter: 'date:"short"'},
                {field: 'doc.name', name: 'Recorder'},
            ],
            showGroupPanel: true,
        };

        $scope.reloadData();
    });

angular.module('DataBrowserModule')
    .controller('CompletedTetradsController', function($scope, $resource, $templateCache) {

        $scope.dataType = 'Completed Tetrads';
        $scope.uploadUrl = '/bulk/completed.csv';
        $scope.resource = $resource(
            '/mossmap/_design/mossmap/_view/completed-tetrads?startkey=["set=:setId"]&endkey=["set=:setId",{}]',
            {setId: '@id'}
        );
        
        $scope.gridOptions = {
            enableHorizontalScrollbar: 0,
            enableFiltering: true,
            showGridFooter: true,
            gridFooterTemplate:  $templateCache.get('footer.html'),
//            footerRowHeight: 40,
            data: 'data.rows',
            columnDefs: [
                {field: 'key[1]', name: 'Grid Ref', width: 100},
            ],
            showGroupPanel: false,
        };
 
        $scope.reloadData();
    });


angular.module('DataBrowserModule')
    .controller('LoginController', function($scope, $uibModalInstance, session) {
        $scope.session = session;
        
        $scope.ok = function ok() {

            function onSuccess(response) {
                if (response.status == 200)
                    $uibModalInstance.close();
            }

            function onFailure(response) {
                // Login failed for abnormal reasons
                $scope.error = {
                    response: response,
                    reason: "unable to login",
                };
            }

            session.logIn($scope.name, $scope.password)
                .then(onSuccess, onFailure);
        };

        $scope.cancel = function cancel() {
            $uibModalInstance.dismiss();
        };

    });

angular.module('DataBrowserModule')
    .controller('LogoutController', function($scope, $http, $uibModalInstance, session) {
        $scope.ok = function() {
            session.logOut();
            $uibModalInstance.dismiss();
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
            // (Assumes we're invoked by form's ng-submit/click)

            var fileInput = angular.element(inputSelector);
            
            var node = fileInput.get(0);
            if (!node.files.length)
                return;

            var file = node.files[0];
            
            // console.log("upload"); // DEBUG
            var reader = new FileReader();
            
            // Set the handler
            reader.onload = function() {
                // console.log("onload "); // DEBUG
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
                            $scope.uploadMessage = "Error: "+resp.statusText;
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
}());
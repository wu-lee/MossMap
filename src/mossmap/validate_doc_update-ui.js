
function (newDoc, oldDoc, userCtx) {
    function forbidden(message) {    
        throw({forbidden : message});
    };
    
    function unauthorized(message) {
        throw({unauthorized : message});
    };
    
    function hasRole(name) {
        userCtx.roles.indexOf(name) !== -1;
    }
    
    if (!hasRole('_admin')) {
        unauthorized("Only admins may modify or create documents.");
    }
}

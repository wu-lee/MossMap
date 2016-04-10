module.exports = {

    /** Collapses a sequence of tuples into a nested array of arrays of...
     */
    nestOnto: function(size, cursor) {
        var result = [];

        var ix, last, key, nested;

        while (true) {
            var fields = cursor();
            if (!fields) break;

            var sr = result;
            for(ix = 0; ix < size-3; ix += 1) {
                last = sr.length-1;
                key = fields[ix];
                nested = 
                    sr.length === 0?     (sr[0] = [key,[]]) :
                    sr[last][0] === key? sr[last] :
                                         (sr[sr.length] = [key,[]]);
                sr = nested[1];
            }

            // Deepest 3 levels encoded as an object not a nested array.
            // This is for historical reasons.
            key = fields[ix++];
            last = sr.length-1;
            nested = 
                sr.length === 0?     (sr[0] = [key,{}]) :
                sr[last][0] === key? sr[last] :
                                     (sr[sr.length] = [key,{}]);

            sr = nested[1];
            key = fields[ix++];
            sr[key] = fields[ix];
        }
        // console.log(JSON.stringify(result)); // DEBUG
        return result;
    }
};
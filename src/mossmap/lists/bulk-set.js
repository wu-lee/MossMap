// For use with the records view

(function (head, req) {
    var utils = require('js/mossmap-utils');
    // specify that we're providing a JSON response
    provides('json', function() {

        // create an array for our result set
        function cursor() {
            var data = getRow();
            return data? [].concat(data.key, data.value) : data;
        }
        var index = utils.nestOnto(5, cursor);

        // make sure to stringify the results :)
        var data = {completed:[],taxa:index[0][1]};
        send(JSON.stringify(data));
    });
});

/*
(function (head, req) {
    // specify that we're providing a JSON response
    provides('json', function() {

        // create an array for our result set
        var index = {};
        var key;
        while (true) {
            var row = getRow();
            if (!row) break;

            var ptr = index;
            for(var ix = 0; ix < row.key.length-1; ix++) {
                key = row.key[ix];
                if (!ptr[key])
                    ptr = ptr[key] = {};
                else
                    ptr = ptr[key];
            }
            key = row.key[ix];
            if (ptr[key])
                ptr[key] += row.value;
            else
                ptr[key] = row.value;
        }

        // make sure to stringify the results :)
        var data = {completed:[],taxa:index};
        send(JSON.stringify(data));
    });
});
{
  "completed": [],
  "taxa": [
    [
      "Aloina aloides",
      [
        [
          "SJ4277",
          {
            "20110321": 1
          }
        ],
        [
          "SJ5060783298",
          {
            "20130104": 1
          }
        ],
        [
          "SJ5379",
          {
            "20020202": 1
          }
        ],
        [
          "SJ5482",
          {
            "20130220": 1
          }
        ],
        [
          "SJ5785",
          {
            "20020616": 1,
            "20130320": 1
          }
        ],
        [
          "SJ58",
          {
            "19940415": 1
          }
        ],
        [
          "SJ656680",
          {
            "20011204": 1
          }
        ],
        [
          "SJ77C",
          {
            "19760410": 1
          }
        ]
      ]
    ]
  ]
}
*/

(function(doc) {
    // Select only records
    if (doc._id.lastIndexOf('record=', 0) !== 0)
        return;
    
    emit(doc.dataSet);
});

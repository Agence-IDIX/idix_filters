/**
 * Created by quentinmachard on 19/05/15.
 */
CKEDITOR.plugins.add('px_clean', {
    init: function(editor) {},
    afterInit: function(editor) {
        var emptyParagraph = {
            elements : {
                p : function( element ) {
                    if(element.children.length == 1) {
                        if(element.children[0].isEmpty) {
                            return false;
                        }
                    }
                    return element;
                }
            }
        };

        var dataProcessor = editor.dataProcessor,
            dataFilter = dataProcessor && dataProcessor.dataFilter,
            htmlFilter = dataProcessor && dataProcessor.htmlFilter;

        if(dataFilter) dataFilter.addRules(emptyParagraph, 100);
        if(htmlFilter) htmlFilter.addRules(emptyParagraph, 100);

    }
});
(function ($) {
    Drupal.behaviors.idix_textarea = {
        attach: function(context) {
            var $context = $(context);
            var idixCkeditors = $context.find('[data-idix-wordcount="enabled"],[data-idix-editor-class]');
            if(idixCkeditors.length > 0){
                idixCkeditors.each(function(){
                    var datas = $(this).data();
                    var selector = datas.drupalSelector;
                    var ckInstance = CKEDITOR.instances[selector];
                    ckInstance.once('configLoaded', Drupal.behaviors.idix_textarea._initEditor.bind({datas:datas}));
                });
            }
        },
        _countLess:function(currentLength, maxLength) {
            var instance = CKEDITOR.instances[this.identifier];
            if (typeof(instance) === 'undefined') {
                return;
            }
            if (currentLength === 0) {
                instance.container.removeClass('cke_error').removeClass('cke_success');
                return;
            }
            instance.container.removeClass('cke_error').addClass('cke_success');
        },
        _countGreater: function(currentLength, maxLength) {
            var instance = CKEDITOR.instances[this.identifier];
            if (typeof(instance) === 'undefined') {
                return;
            }
            instance.container.removeClass('cke_success').addClass('cke_error');
        },
        _initEditor: function(evt){
            if(typeof this.datas.idixWordcount != 'undefined' && this.datas.idixWordcount == 'enabled') {
                evt.editor.config.wordcount.showParagraphs = typeof this.datas.idixWordcountShowparagraphs != 'undefined';
                evt.editor.config.wordcount.showWordCount = typeof this.datas.idixWordcountShowwordcount != 'undefined';
                evt.editor.config.wordcount.showCharCount = typeof this.datas.idixWordcountShowcharcount != 'undefined';
                evt.editor.config.wordcount.countSpacesAsChars = typeof this.datas.idixWordcountCountspacesaschars != 'undefined';
                evt.editor.config.wordcount.countHTML = typeof this.datas.idixWordcountCounthtml != 'undefined';
                evt.editor.config.wordcount.hardLimit = false;
                var maxCharCount = -1;
                var limitOverride = false;
                if (typeof this.datas.idixWordcountOverrideField != 'undefined' && this.datas.idixWordcountOverrideField != '' && this.datas.idixWordcountOverrideField != '_none') {
                    var fieldName = this.datas.idixWordcountOverrideField;
                    fieldName = fieldName.replace(/_/g, '-');
                    var fieldLimit = $('[data-drupal-selector="edit-' + fieldName + '-0-limite"]');
                    if (fieldLimit.length > 0) {
                        maxCharCount = fieldLimit.val();
                        limitOverride = true;
                        if (maxCharCount == '_none') {
                            maxCharCount = -1;
                        }
                        $('body').one('change', fieldLimit, Drupal.behaviors.idix_textarea._changeLimit.bind({datas: this.datas}));
                    }
                }
                if (!limitOverride) {
                    evt.editor.config.wordcount.maxWordCount = typeof this.datas.idixWordcountMaxwordcount != 'undefined' ? this.datas.idixWordcountMaxwordcount : -1;
                    maxCharCount = typeof this.datas.idixWordcountMaxcharcount != 'undefined' ? this.datas.idixWordcountMaxcharcount : -1;
                }
                evt.editor.config.wordcount.maxCharCount = maxCharCount;
                if (maxCharCount != -1) {
                    evt.editor.config.wordcount.charCountGreaterThanMaxLengthEvent = Drupal.behaviors.idix_textarea._countGreater.bind({identifier: this.datas.drupalSelector});
                    evt.editor.config.wordcount.charCountLessThanMaxLengthEvent = Drupal.behaviors.idix_textarea._countLess.bind({identifier: this.datas.drupalSelector});
                }
            }
            if(typeof this.datas.idixEditorClass != 'undefined' && this.datas.idixEditorClass != ''){
                evt.editor.config.bodyClass += ' ' + this.datas.idixEditorClass;
            }
        },
        _changeLimit: function(evt){
            if($(evt.target).data('drupalSelector').match(/edit-(.*)-0-limite/)) {
                var datas = this.datas;
                var selector = datas.drupalSelector;
                var ckInstance = CKEDITOR.instances[selector];
                var ckConfig = ckInstance.config;
                ckInstance.destroy();
                ckInstance = CKEDITOR.replace(selector, ckConfig);
                ckInstance.once('configLoaded', Drupal.behaviors.idix_textarea._initEditor.bind({datas: datas}));
            }
        }
    };
})(jQuery);

(function($, window, Drupal, drupalSettings) {
    'use strict';

    Drupal.AjaxCommands.prototype.idixTextareaReload = function(ajax, response, status) {
        window.setTimeout(function(){
            $(response.selector).trigger('change');
        }.bind(response), 2000);
    };

})(jQuery, this, Drupal, drupalSettings);
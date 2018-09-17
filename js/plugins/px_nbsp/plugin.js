/**
 * Created by quentinmachard on 28/12/2015.
 */
(function ($) {
	CKEDITOR.plugins.add('px_nbsp', {
		lang: "en,fr",
		init: function(editor) {
			var self = this;

			/**
			 * List of available spaces
			 * @type {string[]}
			 */
			self.availableSpaces = ['nbsp', 'thinsp'];

			// Config
			var default_config = {
				defaultSpace: 'nbsp',
				authorizedSpaces: ['nbsp', 'thinsp'],
				spacePattern: '[px_nbsp:%type]'
			};

			// Style of fakeElement
			editor.addContentsCss(this.path + 'style.css');

			// Get Config
			self.config = CKEDITOR.tools.extend(default_config, editor.config.px_nbsp || {}, true);

			/**
			 * Command to insert a NBSP
			 */
			for(var i= 0, type; type = self.config.authorizedSpaces[i]; i++) {
				// If type is configured
				if(self.availableSpaces.indexOf(type) > -1) {
					editor.addCommand( 'px_nbsp_' + type, {
						exec: function( editor ) {
							var type = this.name.replace('px_nbsp_', '');
							editor.insertText(self.config.spacePattern.replace('%type', type));
						}
					});

					editor.ui.addButton( 'px_nbsp_' + type, {
						label : editor.lang.px_nbsp.buttonLabel + ' ' + editor.lang.px_nbsp.buttonType[type],
						command : 'px_nbsp_' + type,
						icon : this.path + 'icons/icon-' + type + '.png',
						toolbar: 'px_nbsp'
					});
				}
			}

			// Add key command to add default space
			editor.setKeystroke( CKEDITOR.ALT + 32 /* space */, 'px_nbsp_' + self.config.defaultSpace );
		},

		afterInit: function(editor) {
			var self = this;

			var dataProcessor = editor.dataProcessor,
				dataFilter = dataProcessor && dataProcessor.dataFilter;

			var rules = {
				text: function(text) {
					var pattern = self.getPattern();

					return text.replace(pattern, function(text) {
						var type = self.getType(text);

						// If is an authorized space
						if(type.length > 0 && self.config.authorizedSpaces.indexOf(type) > -1) {
							var writer = new CKEDITOR.htmlParser.basicWriter();

							// Real element
							var realElement = getRealElement(type);

							var tmp = editor.createFakeParserElement(realElement, 'px_nbsp '+type, type, false);
							tmp.writeHtml(writer);

							return writer.getHtml();
						}

						return '';
					});
				},
				elements: {
					img: function(element) {
						var type = element.attributes['data-cke-real-element-type'] || '';

						if(self.config.authorizedSpaces.indexOf(type) > -1) {
							return getRealElement(type);
						}
					}
				}
			};

			var getRealElement = function(type) {
				var realFragment = new CKEDITOR.htmlParser.fragment.fromHtml(self.config.spacePattern.replace('%type', type));
				var realElement = realFragment && realFragment.children[0];
				realElement.attributes = {};

				return realElement;
			};

			if (dataFilter) dataFilter.addRules(rules);
		},

		/**
		 * Nettoyage des espaces insécables indésirable
		 * et remplacement des fakeElements par des vrais
		 *
		 * @param editor
		 */
		cleanDataEditor: function(editor) {
			editor.setData(this.cleanHtml(editor.getData()));
		},

		/**
		 * Get html with fake spaces replaced by real spaces
		 * and remove undesirable spaces
		 * @param txt
		 * @returns {string}
		 */
		cleanHtml: function(txt) {
			var self = this;

			// Remove all undesirable spaces
			for(var i= 0, space; space = self.availableSpaces[i]; i++) {
				txt = txt.replace(new RegExp('&'+space+';', 'g'), ' ');
			}

			// Replace tags by real spaces
			var pattern = self.getPattern();
			txt = txt.replace(pattern, function(match) {
				var type = self.getType(match);

				// If space is authorized
				if(self.config.authorizedSpaces.indexOf(type) > -1) {
					return '&'+type+';';
				}

				return '';
			});

			return txt;
		},

		/**
		 * Remplacement des espaces insécables par des fakeElements
		 * et suppression des espaces insécables indésirables
		 *
		 * @param editor
		 */
		unCleanDataEditor: function(editor) {
			editor.setData(this.unCleanHtml(editor.getData()));
		},

		/**
		 * Get html with tags on place of space
		 * @param text
		 */
		unCleanHtml: function(text) {
			var self = this;


			// Replace spaces per fakeElements
			for(var i= 0, type; type = self.config.authorizedSpaces[i]; i++) {
				text = text.replace(new RegExp('&'+type+';', 'g'), self.config.spacePattern.replace('%type', type));
			}

			// Remove spaces in empty <p>
			var pattern = new RegExp('<p>\\s*' + self.getPattern(true) + '\\s*</p>', 'g');
			text = text.replace(pattern, '<p></p>');

			return text;
		},

		/**
		 * Insert a space
		 *
		 * @param editor
		 * @param type Type of space (nbsp, thinsp, etc.)
		 */
		insertSpace: function(editor, type) {
			var self = this;
			if(self.config.authorizedSpaces.indexOf(type) > -1) {
				editor.execCommand('px_nbsp:' + type);
			}
		},

		/**
		 * Get the custom pattern
		 *
		 * @returns {RegExp|string}
		 */
		getPattern: function(textOnly) {
			textOnly = textOnly || false;

			var pattern = this.config.spacePattern.replace(/[.?*+^$[\]\\(){}|-]/g, "\\$&").replace('%type', '([a-z]+)');

			if(textOnly) {
				return pattern;
			} else {
				return new RegExp(pattern, 'g');
			}
		},

		/**
		 * Get the type of element
		 * @param text
		 * @returns {string}
		 */
		getType: function(text) {
			var type = '', match;
			var pattern = this.getPattern();

			// Getting type
			while ((match = pattern.exec(text)) !== null) {
				if (match.index === pattern.lastIndex) {
					pattern.lastIndex++;
				}
				type =  match[1];
			}
			return type;
		}
	});
})(jQuery);
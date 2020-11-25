/****************************************************/
/************** Début configuration *****************/
/****************************************************/

// Url du proxy ou directement du WebService.
//
var sDiagPlWsUrlProxy = location.protocol + "//"+ location.host +"/modules/custom/idix_filters/js/plugins/DiagPlWs/proxyDiagPlWs.php";



/****************************************************/
/*************** Fin configuration ******************/
/****************************************************/

// Fonction de chargement dynamique de fichier Js
//
function loadJsFile(filename){
	var fileref = top.document.createElement('script');
	fileref.setAttribute("type", "text/javascript");
	fileref.setAttribute("charset", "utf-8");
	fileref.setAttribute("src", filename);
	top.document.getElementsByTagName("head")[0].appendChild(fileref);
}

CKEDITOR.plugins.add('DiagPlWs',
	{
		init: function(editor)
		{
			var pluginName = 'DiagPlWs';
			editor.addCommand(pluginName, {exec: DiagPlWsCmd, modes: {wysiwyg: 1}, editorFocus: false});
			editor.ui.addButton(pluginName,
				{
					label: 'Analyse ProLexis',
					command: pluginName,
					icon: CKEDITOR.plugins.getPath('DiagPlWs') + 'core/imgs/DiagPlWsIcon.png'
				});

			pluginName += 'En';
			editor.addCommand(pluginName, {exec: DiagPlWsCmdEn, modes: {wysiwyg: 1}, editorFocus: false});
			editor.ui.addButton(pluginName,
				{
					label: 'Analyse anglaise ProLexis',
					command: pluginName,
					icon: CKEDITOR.plugins.getPath('DiagPlWs') + 'core/imgs/DiagPlWsIcon-en.png'
				});

			// Chargement en évitant de le faire deux fois.
			//
			if (typeof top.DiagPlWs == "undefined") {
				loadJsFile(CKEDITOR.plugins.getPath('DiagPlWs') + 'core/DiagPlWs.js');
			}
		}
	});


function DiagPlWsCommon(editor, diagPlWsCallBack, lang)
{
	// Initialisation de la callback
	diagPlWsCallBack = diagPlWsCallBack || null;

	// En mode plein écran sous IE6-7, la fenêtre de correction rencontre des
	// problémes d'affichage
	if(CKEDITOR.env.ie6Compat || CKEDITOR.env.ie7Compat){
		var commandFullScreen = editor.getCommand('maximize');
		if(commandFullScreen){
			if(commandFullScreen.state == CKEDITOR.TRISTATE_ON){
				// On bascule en mode écran normal.
				commandFullScreen.exec();
			}
		}
	}

	// Initialisation
	//
	top.DiagPlWs.init({
		sUrlProxy: sDiagPlWsUrlProxy,
		sCorePath: CKEDITOR.plugins.getPath('DiagPlWs') + 'core',
		supportLearn : false, // Cache le bouton des soumissions, par défaut est égal à true
		hCallBack: diagPlWsCallBack
	});

	// Lancement de l'analyse du texte
	//
	top.DiagPlWs.analyze([{
			src: editor,
			type: "ckeditor"
		}],
		{language: lang});
}


// Fonction exécutée lors du clic sur le bouton de la barre d'outil
// diagPlWsCallBack: (optionnel) fonction à lancer à la fin de la phase de correction.
//
function DiagPlWsCmd(editor, diagPlWsCallBack)
{
	DiagPlWsCommon(editor, diagPlWsCallBack, "fr");
}

// Fonction exécutée lors du clic sur le bouton de l'nalyse anglaise
// diagPlWsCallBack: (optionnel) fonction à lancer à la fin de la phase de correction.
//
function DiagPlWsCmdEn(editor, diagPlWsCallBack)
{
	DiagPlWsCommon(editor, diagPlWsCallBack, "en");
}

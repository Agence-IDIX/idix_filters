<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://www.prolexis.com/ProLexisService/v3"  exclude-result-prefixes="soap ns1">
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

	<!-- Chemin ver le dossier core -->
	<xsl:param name="corePath"/>
	<!-- Nom de l'éditeur Web dans lequel on s'intégre -->
	<xsl:param name="editor"/>

	<!-- Index du texte (stream) que l'on analyse -->
	<xsl:param name="stream"/>

	<!-- Les espaces à mettre en valeur -->
	<xsl:param name="hardSpace"/>
	<xsl:param name="thinSpace"/>
	<xsl:param name="halfEm"/>

	<!-- Template de remplacement de chaine -->
	<xsl:template name="replace-string">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="with"/>
		<xsl:choose>
			<xsl:when test="contains($text,$replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:value-of select="$with"/>
				<xsl:call-template name="replace-string">
					<xsl:with-param name="text" select="substring-after($text,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="with" select="$with"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Template de remplacement d'apostrophe -->
	<xsl:template name="escape-apos">
		<xsl:param name="text"/>
		<xsl:call-template name="replace-string">
			<xsl:with-param name="text" select="$text"/>
			<xsl:with-param name="replace" select='"&apos;"'/>
			<xsl:with-param name="with" select='"\&apos;"'/>
		</xsl:call-template>
	</xsl:template>

	<!-- Template de remplacement d'une proposition vide à une image plus significative.
			 text : le texte à traiter.
	-->
	<xsl:template name="replace-delchar">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="$text=''">
				<!-- Proposition vide : suppression -->
				<!--&lt;span class=&quot;Diagplws_pseudo-del&quot;&gt;&lt;img src=&quot;<xsl:value-of select='$corePath' />/imgs/blank.gif&quot; width=&quot;12&quot; height=&quot;13&quot; class=&quot;DiagPlWs_inlineImg&quot; border=&quot;0&quot;/&gt;&lt;/span&gt;-->
				&lt;span&gt;Supprimez la sélection&lt;/span&gt;
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Template de remplacement d'espaces et de caractère de suppression, produit une chaîne échappée.
			 text : le texte à traiter.
	-->
	<xsl:template name="replace-spaces">
		<xsl:param name="text"/>

		<xsl:choose>
			<xsl:when test="$text=''">
				<!-- Proposition vide : suppression -->
				<xsl:call-template name="replace-delchar">
					<xsl:with-param name="text" select="$text"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- Calcul d'une image qui servira d'espaceur -->
				<xsl:variable name="spacerString">&lt;img src=&quot;<xsl:value-of select='$corePath' />/imgs/blank.gif&quot; width=&quot;12&quot; height=&quot;13&quot; class=&quot;DiagPlWs_inlineImg&quot; border=&quot;0&quot;/&gt;</xsl:variable>

				<!-- Passe 1 : remplacement des espaces -->
				<xsl:variable name="pass1">
					<xsl:call-template name="replace-string">
						<xsl:with-param name="text" select="$text"/>
						<xsl:with-param name="replace" select="' '"/>
						<xsl:with-param name="with">&lt;span class=&quot;Diagplws_pseudo-sp&quot;&gt;<xsl:value-of select="$spacerString"/>&lt;/span&gt;</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<!-- Passe 2 : remplacement des espaces insécables -->
				<xsl:variable name="pass2">
					<xsl:call-template name="replace-string">
						<xsl:with-param name="text" select="$pass1"/>
						<xsl:with-param name="replace" select="$hardSpace"/>
						<xsl:with-param name="with">&lt;span class=&quot;Diagplws_pseudo-nbsp&quot;&gt;<xsl:value-of select="$spacerString"/>&lt;/span&gt;</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<!-- Passe 3 : remplacement des espaces fines -->
				<xsl:variable name="pass3">
					<xsl:call-template name="replace-string">
						<xsl:with-param name="text" select="$pass2"/>
						<xsl:with-param name="replace" select="$thinSpace"/>
						<xsl:with-param name="with">&lt;span class=&quot;Diagplws_pseudo-thinsp&quot;&gt;<xsl:value-of select="$spacerString"/>&lt;/span&gt;</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<!-- Passe 4 : remplacement des demis quadratins (en space) -->
				<xsl:call-template name="replace-string">
					<xsl:with-param name="text" select="$pass3"/>
					<xsl:with-param name="replace" select="$halfEm"/>
					<xsl:with-param name="with">&lt;span class=&quot;Diagplws_pseudo-ensp&quot;&gt;<xsl:value-of select="$spacerString"/>&lt;/span&gt;</xsl:with-param>
				</xsl:call-template>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Template racine (ou presque)
		Génération du HTML qui sera affiché dans l'interface de correction.
	-->
	<xsl:template match="/soap:Envelope/soap:Body/ns1:analyzeResponse/analyzerOutput">
		<xsl:apply-templates select="correctionSessionId" />

		<!-- Traitement des données d'erreurs -->
		<xsl:apply-templates select="errors" />

		<!--<xsl:choose>
			<xsl:when test="contains($editor,'CCI') or contains($editor,'syceron') or contains($editor,'trias')">
				<div class="Diagplws_column">
					<div class="Diagplws_content Diagplws_diagnosis_panel">
					<p class="Diagplws_legend">Diagnostic</p>
					<div class="Diagplws_diagnosis">
						<span><br/></span>
					</div>
					</div>
					<div class="Diagplws_content Diagplws_text_btn_content">
					<div class="Diagplws_text_btn">
					<span id="Diagplws_decrease_btn" class="Diagplws_ui_reset"><img src="{$corePath}/imgs/DiagPlWsDown.png" title="Diminuer la taille du texte" alt="-" /></span>
					<img src="{$corePath}/imgs/DiagPlWsLetter.png" title="Taille du texte" alt="A" />
					<span id="Diagplws_increase_btn" class="Diagplws_ui_reset"><img src="{$corePath}/imgs/DiagPlWsUp.png" title="Augmenter la taille du texte" alt="+" /></span>
					</div>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="mdl-card Diagplws_content Diagplws_diagnosis_panel">
				<div class="mdl-card__title Diagplws_legend">Diagnostic</div>
				<div class="Diagplws_diagnosis">
					<br/>
				</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>-->

		<!--<div class="mdl-card Diagplws_content Diagplws_props_panel">
			<div class="mdl-card__title Diagplws_legend">Corrections proposées</div>
			<div class="Diagplws_props">
				<br/>
			</div>
		</div>
		<div class="mdl-card Diagplws_content Diagplws_correction_panel">
			<div class="mdl-card__title Diagplws_legend">Correction manuelle</div>
			<div class="Diagplws_correction">
			<xsl:choose>
			<xsl:when test="contains($editor,'CCI') or contains($editor,'syceron') or contains($editor,'trias')">
				<input class="Diagplws_correction_input" type="text" />
				<div class="Diagplws_correction_label" style="display: none;">&#xA0;</div>
				<button class="Diagplws_correction_button" id="Diagplws_correction_btn">Corriger</button>
				<button class="Diagplws_correction_button" id="Diagplws_correctionmultiple_btn">… fois</button>
			</xsl:when>
			<xsl:otherwise>
				<input class="Diagplws_correction_input mdl-textfield__input" type="text" id="txt_correction" />
				<button class="mdl-button mdl-js-button mdl-js-ripple-effect Diagplws_correction_button" id="Diagplws_correction_btn">Corriger</button>
				<button class="mdl-button mdl-js-button mdl-js-ripple-effect Diagplws_correction_button" id="Diagplws_ignorer_btn" title="Ignorer l'anomalie">Ignorer</button><br/>
			</xsl:otherwise>
			</xsl:choose>
			</div>
		</div>-->
	</xsl:template>

	<!-- Template du retour après traitement d'une erreur par le WebService.
	-->
	<xsl:template match="/soap:Envelope/soap:Body/ns1:correctResponse/return|/soap:Envelope/soap:Body/ns1:ignoreResponse/return">
		<!-- Traitement des données d'erreurs -->
		<xsl:apply-templates select="errors" />
		<input type="hidden" id="Diagplws_selectedError" name="Diagplws_selectedError" value="{selectedError}" />
		<input type="hidden" id="Diagplws_textCheckSum" name="Diagplws_textCheckSum" value="{textCheckSum}" />
	</xsl:template>


	<!--  Template pour la session de correction
	-->
	<xsl:template match="correctionSessionId">
		<input type="hidden" id="Diagplws_sessionid" name="Diagplws_sessionid" value="{.}" />
	</xsl:template>

	<!-- Template des données de la liste des erreurs
	-->
	<xsl:template match="errors">
		<div class="Diagplws_table">
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<!-- Template pour une erreur -->
	<xsl:template match="error">
		<!-- Pour une question de présentation on remplace les ; par des sauts de ligne -->
		<xsl:variable name="diagnosis">
			<xsl:call-template name="replace-string">
				<xsl:with-param name="text" select="data/diagnosis"/>
				<xsl:with-param name="replace" select="';'"/>
				<xsl:with-param name="with" select="'&lt;br/&gt;'"/>
			</xsl:call-template>
		</xsl:variable>

		<!--  Propositions de correction -->
		<xsl:variable name="props">
			<xsl:call-template name="proposals">
				<xsl:with-param name="errorType" select="header/type"/>
				<xsl:with-param name="duplicateErrorCount" select="header/duplicateErrorCount"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Classe du label -->
		<xsl:variable name="labelClass">
			<xsl:choose>
				<xsl:when test="header/type='1'">
					<!-- Erreur ortho -->
					<xsl:value-of select="'Diagplws_errorOrtho'"/>
				</xsl:when>
				<xsl:when test="header/type='2'">
					<!-- Erreur grammaire -->
					<xsl:value-of select="'Diagplws_errorGram'"/>
				</xsl:when>
				<xsl:when test="header/type='3'">
					<!-- Erreur typo -->
					<xsl:value-of select="'Diagplws_errorTypo'"/>
				</xsl:when>
				<xsl:when test="header/type='4'">
					<!-- Erreur contexte -->
					<xsl:value-of select="'Diagplws_errorContext'"/>
				</xsl:when>
				<xsl:when test="header/type='5'">
					<!-- Erreur fréquence -->
					<xsl:value-of select="'Diagplws_errorFrequency'"/>
				</xsl:when>
				<xsl:when test="header/type='6'">
					<!-- Erreur presse -->
					<xsl:value-of select="'Diagplws_errorPress'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Classe CSS suivant le statut de l'erreur à traiter / ignorée-corrigée -->
		<xsl:variable name="labelClassStatus">
			<xsl:choose>
				<xsl:when test="header/status='0'">
					<!-- Status à traiter -->
					<xsl:value-of select="''"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'Diagplws_errorinactive'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Label de l'erreur -->
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="data/label">
					<xsl:value-of select="data/label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'&#xA0;'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<a class="Diagplws_errorLine" href="">
			<span class="Diagplws_errorLabel {$labelClass} {$labelClassStatus}" Diagplws_offset="{header/location/offset}" Diagplws_length="{header/location/length}" Diagplws_duplicateErrorCount="{header/duplicateErrorCount}" Diagplws_duplicateNextErrorId="{header/duplicateNextErrorId}" Diagplws_props="{$props}" Diagplws_diagnosis="{$diagnosis}" data-diagplws_status="{header/status}" data-diagplws_flags="{data/flags}" data-stream="{$stream}">
				<xsl:choose>
					<xsl:when test="header/type='3'">
						<!-- Pour contrer certaines disparitions d'espace simple, on les remplace
                             par un caractère incongrue (remplacé à l'affichage).
                        -->
						<xsl:call-template name="replace-string">
							<xsl:with-param name="text" select="$label"/>
							<xsl:with-param name="replace" select="' '"/>
							<xsl:with-param name="with" select="'˽'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$label"/>
					</xsl:otherwise>
				</xsl:choose>
			</span>
		</a>
	</xsl:template>

	<!-- Template des propositions
	     Génération du contenu texte html qui sera inséré par javascript
	-->
	<xsl:template name="proposals">
		<xsl:param name="errorType"/>
		<xsl:param name="duplicateErrorCount"/>

		<!--  Pour chaque proposition -->
		<xsl:for-each select="data/corrections">
			<xsl:for-each select="item">
				<xsl:if test="position() &lt;= 5">
					<xsl:text>&lt;div class=&quot;Diagplws_prop-container&quot;&gt;</xsl:text>
					<!-- Ajouter un bouton  -->
					<xsl:text>&lt;button class=&quot;mdl-button mdl-js-button mdl-js-ripple-effect Diagplws_prop_button&quot;&gt;</xsl:text>
					<xsl:call-template name="proposal">
						<!-- Echappement / remplacement du texte de remplacement -->
						<xsl:with-param name="prop" select="."/>
						<xsl:with-param name="errorType" select="$errorType"/>
					</xsl:call-template>
					<xsl:text>&lt;/button&gt;</xsl:text>

					<xsl:if test="$duplicateErrorCount &gt; 0">
						<xsl:text>&lt;button class=&quot;mdl-button mdl-js-button mdl-js-ripple-effect Diagplws_propmultiple_button&quot;&gt;&lt;span Diagplws_proposal=&quot;</xsl:text><xsl:value-of select="."/><xsl:text>&quot;&gt;x&amp;#xA0;</xsl:text><xsl:value-of select="$duplicateErrorCount+1"/><xsl:text>&lt;/span&gt;&lt;/button&gt;</xsl:text>
					</xsl:if>
					<xsl:text>&lt;/div&gt;</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<!-- Template pour une proposition
			 Génération du contenu texte html et javacript inséré par javascript
	-->
	<xsl:template name="proposal">
		<xsl:param name="prop"/>
		<xsl:param name="errorType"/>

		<!-- Echappement du texte des propositions -->
		<xsl:variable name="replace">
			<xsl:choose>
				<!-- Pour les erreurs de typo, on modifie les espaces -->
				<xsl:when test="$errorType='3'">
					<xsl:call-template name="replace-spaces">
						<xsl:with-param name="text" select="$prop"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- Pour toutes les erreurs, on tente le remplacement des propositions vides
					par un caractère plus significatif -->
					<xsl:call-template name="replace-delchar">
						<xsl:with-param name="text" select="$prop"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:text>&lt;span class=&quot;Diagplws_proposal&quot; Diagplws_proposal=&quot;</xsl:text>
		<!--Ce n'est pas la peine d'avoir les espaces modifiée dans la modification effective -->
		<xsl:value-of select="$prop"/>
		<xsl:text>&quot;&gt;</xsl:text>
		<xsl:value-of select="$replace"/>
		<xsl:text>&#xA0;&lt;/span&gt;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
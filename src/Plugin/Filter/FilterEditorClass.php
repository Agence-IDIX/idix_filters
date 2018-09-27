<?php

namespace Drupal\idix_filters\Plugin\Filter;

use Drupal\Core\Form\FormStateInterface;
use Drupal\filter\FilterProcessResult;
use Drupal\filter\Plugin\FilterBase;

/**
 * @Filter(
 *   id = "filter_editor_class",
 *   title = @Translation("Ajout de classe(s) css à l'éditeur - Filtre BO uniquement"),
 *   description = @Translation("Permet d'ajouter une ou plusieurs classes CSS à l'éditeur de texte, afin d'obtenir le même rendu qu'en Front Office"),
 *   type = Drupal\filter\Plugin\FilterInterface::TYPE_MARKUP_LANGUAGE,
 *   settings = {
 *     "editor_class" = ""
 *   },
 *   weight = -10
 * )
 */
class FilterEditorClass extends FilterBase {

  public function process($text, $langcode) {
    return new FilterProcessResult($text);
  }

  /**
   * {@inheritdoc}
   */
  public function settingsForm(array $form, FormStateInterface $form_state) {
    $form['editor_class'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Classe(s) de l\'éditeur'),
      '#default_value' => $this->settings['editor_class'],
      '#description' => $this->t('Une liste de classe(s) CSS à ajouter à l\'éditeur. Permet d\'appliquer le même rendu au texte qu\'en Front Office.'),
    ];
    return $form;
  }

}

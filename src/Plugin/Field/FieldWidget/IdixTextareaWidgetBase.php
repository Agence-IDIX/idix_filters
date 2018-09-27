<?php

namespace Drupal\idix_filters\Plugin\Field\FieldWidget;

use Drupal\Core\Field\FieldItemListInterface;
use Drupal\Core\Form\FormStateInterface;
use Drupal\field\Entity\FieldConfig;
use Drupal\text\Plugin\Field\FieldWidget\TextareaWidget;

abstract class IdixTextareaWidgetBase extends TextareaWidget {
  /**
   * {@inheritdoc}
   */
  public static function defaultSettings() {
    return [
      'wordcount_enable' => false,
      'wordcount_showParagraphs' => false,
      'wordcount_showWordCount' => false,
      'wordcount_showCharCount' => false,
      'wordcount_countSpacesAsChars' => false,
      'wordcount_countHTML' => false,
      'wordcount_maxWordCount' => -1,
      'wordcount_maxCharCount' => -1,
      'wordcount_override_field' => '',
    ] + parent::defaultSettings();
  }

  /**
   * {@inheritdoc}
   */
  public function settingsForm(array $form, FormStateInterface $form_state) {
    $elements = parent::settingsForm($form, $form_state);

    $field_definitions = \Drupal::service('entity_field.manager')->getFieldDefinitions($form['#entity_type'], $form['#bundle']);

    $limitation_fields = [];
    foreach($field_definitions as $field){
      if($field instanceof FieldConfig && $field->getType() == 'limitation'){
        $limitation_fields[] = $field;
      }
    }

    $elements['wordcount_enable'] = array(
      '#type' => 'checkbox',
      '#title' => $this->t('Enable the counter'),
      '#default_value' => $this->getSetting('wordcount_enable'),
    );

    $elements['wordcount_showParagraphs'] = array(
      '#type' => 'checkbox',
      '#title' => $this->t('Show the paragraphs count'),
      '#default_value' => $this->getSetting('wordcount_showParagraphs'),
    );

    $elements['wordcount_showWordCount'] = array(
      '#type' => 'checkbox',
      '#title' => $this->t('Show the word count'),
      '#default_value' => $this->getSetting('wordcount_showWordCount'),
    );

    $elements['wordcount_showCharCount'] = array(
      '#type' => 'checkbox',
      '#title' => $this->t('Show the character count'),
      '#default_value' => $this->getSetting('wordcount_showCharCount'),
    );

    $elements['wordcount_countSpacesAsChars'] = array(
      '#type' => 'checkbox',
      '#title' => $this->t('Count spaces as characters'),
      '#default_value' => $this->getSetting('wordcount_countSpacesAsChars'),
    );

    $elements['wordcount_countHTML'] = array(
      '#type' => 'checkbox',
      '#title' => $this->t('Count HTML as characters'),
      '#default_value' => $this->getSetting('wordcount_countHTML'),
    );

    $elements['wordcount_maxWordCount'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Maximum word limit'),
      '#description' => $this->t('Enter a maximum word limit. Leave this set to -1 for unlimited.'),
      '#default_value' => $this->getSetting('wordcount_maxWordCount'),
    );

    $elements['wordcount_maxCharCount'] = array(
      '#type' => 'textfield',
      '#title' => $this->t('Maximum character limit'),
      '#description' => $this->t('Enter a maximum character limit. Leave this set to -1 for unlimited.'),
      '#default_value' => $this->getSetting('wordcount_maxCharCount'),
    );

    if(count($limitation_fields) > 0){
      $limitation_options = [];
      $limitation_options['_none'] = '- Aucun -';
      foreach($limitation_fields as $field){
        $limitation_options[$field->getName()] = $field->getLabel();
      }

      $elements['wordcount_override_field'] = [
        '#type' => 'select',
        '#title' => 'Surcharger la limite de caractères selon la valeur d\'un autre champ',
        '#options' => $limitation_options,
        '#default_value' => $this->getSetting('wordcount_override_field')
      ];
    }

    $elements['wordcount_maxWordCount']['#element_validate'][] = [$this, 'isNumeric'];
    $elements['wordcount_maxCharCount']['#element_validate'][] = [$this, 'isNumeric'];

    return $elements;
  }

  /**
   * {@inheritdoc}
   */
  public function settingsSummary() {
    $summary = parent::settingsSummary();

    $summary[] = t('Enable the counter: @enabled', ['@enabled' => $this->getSetting('wordcount_enable') ? 'Yes' : 'No']);
    if($this->getSetting('wordcount_enable')){
      $summary[] = t('Show the paragraphs count: @enabled', ['@enabled' => $this->getSetting('wordcount_showParagraphs') ? 'Yes' : 'No']);
      $summary[] = t('Show the word count: @enabled', ['@enabled' => $this->getSetting('wordcount_showWordCount') ? 'Yes' : 'No']);
      $summary[] = t('Show the character count: @enabled', ['@enabled' => $this->getSetting('wordcount_showCharCount') ? 'Yes' : 'No']);
      $summary[] = t('Count spaces as characters: @enabled', ['@enabled' => $this->getSetting('wordcount_countSpacesAsChars') ? 'Yes' : 'No']);
      $summary[] = t('Count HTML as characters: @enabled', ['@enabled' => $this->getSetting('wordcount_countHTML') ? 'Yes' : 'No']);
      $limit_override = false;
      if(!in_array($this->getSetting('wordcount_override_field'), [null, '', '_none'])){
        /** @var \Drupal\field\Entity\FieldConfig $field_def */
        $field_def = $this->fieldDefinition;
        $entity_type = $field_def->getTargetEntityTypeId();
        $bundle = $field_def->getTargetBundle();
        $field_definitions = \Drupal::service('entity_field.manager')->getFieldDefinitions($entity_type, $bundle);
        foreach($field_definitions as $key => $field){
          if($key == $this->getSetting('wordcount_override_field') && $field instanceof FieldConfig && $field->getType() == 'limitation'){
            $limit_override = true;
            $summary[] = 'Limite de caractères surchargées par le champ ' . $field->getLabel();
          }
        }
      }
      if(!$limit_override){
        $summary[] = t('Maximum word limit: @enabled', ['@enabled' => $this->getSetting('wordcount_maxWordCount')]);
        $summary[] = t('Maximum character limit: @enabled', ['@enabled' => $this->getSetting('wordcount_maxCharCount')]);
      }
    }

    return $summary;
  }

  /**
   * @param array $element
   * @param \Drupal\Core\Form\FormStateInterface $form_state
   */
  public function isNumeric(array $element, FormStateInterface $form_state) {
    if (!is_numeric($element['#value'])) {
      $form_state->setError($element, 'Value must be a number.');
    }
  }

  /**
   * {@inheritdoc}
   */
  public function formElement(FieldItemListInterface $items, $delta, array $element, array &$form, FormStateInterface $form_state) {
    $element = parent::formElement($items, $delta, $element, $form, $form_state);

    $editor_class = '';
    if(isset($element['#format']) && !empty($element['#format'])) {
      $format = \Drupal::entityTypeManager()
        ->getStorage('filter_format')
        ->load($element['#format']);
      $filters = is_object($format) ? $format->get('filters') : [];
      $editor_class = (isset($filters['filter_editor_class']) && isset($filters['filter_editor_class']['settings']['editor_class']) && !empty($filters['filter_editor_class']['settings']['editor_class'])) ? trim($filters['filter_editor_class']['settings']['editor_class']) : '';
    }

    $wordcount_enable = $this->getSetting('wordcount_enable');

    if($wordcount_enable || !empty($editor_class)){
      $element['#attached']['library'][] = 'idix_filters/idix_textarea';

      if(!empty($editor_class)) {
        $element['#attributes']['data-idix-editor-class'] = $editor_class;
      }

      $element['#attributes']['data-idix-wordcount'] = $wordcount_enable ? 'disabled' : 'enabled';

      if($wordcount_enable) {
        if ($this->getSetting('wordcount_showParagraphs')) {
          $element['#attributes']['data-idix-wordcount-showParagraphs'] = 'true';
        }
        if ($this->getSetting('wordcount_showWordCount')) {
          $element['#attributes']['data-idix-wordcount-showWordCount'] = 'true';
        }
        if ($this->getSetting('wordcount_showCharCount')) {
          $element['#attributes']['data-idix-wordcount-showCharCount'] = 'true';
        }
        if ($this->getSetting('wordcount_countSpacesAsChars')) {
          $element['#attributes']['data-idix-wordcount-countSpacesAsChars'] = 'true';
        }
        if ($this->getSetting('wordcount_countHTML')) {
          $element['#attributes']['data-idix-wordcount-countHTML'] = 'true';
        }

        if (!in_array($this->getSetting('wordcount_override_field'), [
          NULL,
          '',
          '_none'
        ])
        ) {
          $element['#attributes']['data-idix-wordcount-maxWordCount'] = -1;
          $element['#attributes']['data-idix-wordcount-maxCharCount'] = -1;
          $element['#attributes']['data-idix-wordcount-override-field'] = $this->getSetting('wordcount_override_field');
        }
        else {
          $element['#attributes']['data-idix-wordcount-maxWordCount'] = $this->getSetting('wordcount_maxWordCount');
          $element['#attributes']['data-idix-wordcount-maxCharCount'] = $this->getSetting('wordcount_maxCharCount');
          $element['#attributes']['data-idix-wordcount-override-field'] = '';
        }
      }

    }

    return $element;
  }
}
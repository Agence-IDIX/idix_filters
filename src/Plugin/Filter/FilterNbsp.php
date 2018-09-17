<?php

namespace Drupal\idix_filters\Plugin\Filter;

use Drupal\filter\FilterProcessResult;
use Drupal\filter\Plugin\FilterBase;

/**
 * @Filter(
 *   id = "filter_idix_nbsp",
 *   title = @Translation("Filtre IDIX nbsp"),
 *   description = @Translation("Permet d'insérer des espaces insécables"),
 *   type = Drupal\filter\Plugin\FilterInterface::TYPE_MARKUP_LANGUAGE,
 * )
 */
class FilterNbsp extends FilterBase {

  public function process($text, $langcode) {

    $spacePattern = '[px_nbsp:%type]';
    $authorizedSpaces = array('nbsp', 'thinsp');

    // Remove all undesirables spaces
    $text = preg_replace("'&(".implode('|', $authorizedSpaces).");'i", " ", $text);

    // Transform fake spaces to real spaces
    $text = preg_replace("'".str_replace('%type', '([a-z]+)', preg_quote($spacePattern))."'i", "&$1;", $text);

    return new FilterProcessResult($text);
  }

}
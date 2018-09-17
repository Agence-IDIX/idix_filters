<?php

namespace Drupal\idix_filters\Plugin\CKEditorPlugin;

use Drupal\ckwordcount\Plugin\CKEditorPlugin\Wordcount;

/**
 * Defines the "wordcount" plugin.
 *
 * @CKEditorPlugin(
 *   id = "wordcount",
 *   label = @Translation("PX Word Count & Character Count")
 * )
 */
class PxWordcount extends Wordcount {

  /**
   * {@inheritdoc}
   */
  public function getFile() {
    // Make sure that the path to the plugin.js matches the file structure of
    // the CKEditor plugin you are implementing.
    return drupal_get_path('module', 'idix_filters') . '/js/plugins/px_wordcount/plugin.js';
  }

}
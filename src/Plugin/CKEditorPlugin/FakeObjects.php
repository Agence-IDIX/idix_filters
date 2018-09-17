<?php

namespace Drupal\idix_filters\Plugin\CKEditorPlugin;

use Drupal\ckeditor\CKEditorPluginBase;
use Drupal\editor\Entity\Editor;

/**
 * Defines the "notification" plugin.
 *
 * @CKEditorPlugin(
 *   id = "fakeobjects",
 *   label = @Translation("Fake Objects"),
 * )
 */
class FakeObjects extends CKEditorPluginBase {
  /**
   * {@inheritdoc}
   */
  public function getFile() {
    return 'libraries/fakeobjects/plugin.js';
  }

  /**
   * {@inheritdoc}
   */
  public function getConfig(Editor $editor) {
    return array();
  }

  /**
   * {@inheritdoc}
   */
  public function getButtons() {
    return array();
  }
}
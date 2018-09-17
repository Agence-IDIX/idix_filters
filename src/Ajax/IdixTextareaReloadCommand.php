<?php

namespace Drupal\idix_filters\Ajax;

use Drupal\Core\Ajax\CommandInterface;

class IdixTextareaReloadCommand implements CommandInterface {

  public $selector;

  public function __construct($selector) {
    $this->selector = $selector;
  }

  public function render(){
    return [
      'command' => 'idixTextareaReload',
      'method' => NULL,
      'selector' => $this->selector
    ];
  }

}
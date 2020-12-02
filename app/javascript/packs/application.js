// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("local-time").start()
import jquery from 'jquery';
window.$ = window.jquery = jquery;

window.Rails = Rails

import 'bootstrap'
import 'data-confirm-modal'

require ( 'summernote/dist/summernote-bs4.js' ) ;
// stylesheet for summernote (for Boostrap 4 version)
require ( 'summernote/dist/summernote-bs4.css' ) ;
import 'summernote'

$(document).on("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
	$('.fr-wrapper a:first-child').addClass('hideme');
})

require("trix")
require("@rails/actiontext")
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
// import "../../assets/javascripts/jquery.raty"
// import "../../assets/javascripts/ratyrate.js.erb"
window.$ = window.jquery = jquery;

window.Rails = Rails

import 'bootstrap'
import 'data-confirm-modal'

$(document).on("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
	$('.fr-wrapper a:first-child').addClass('hideme');
})

require("trix")
require("@rails/actiontext")
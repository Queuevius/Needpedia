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

var jQuery = require('jquery')

// include jQuery in global and window scope (so you can access it globally)
// in your web browser, when you type $('.div'), it is actually refering to global.$('.div')
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

import 'select2'
import 'select2/dist/css/select2.css'

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

// Onboarding state: {v:1, choice:'ai'|'no_ai', done:true, at:ISO}
const NP_ONBOARDING_KEY = 'np_onboarding'
window.NpOnboarding = {
  state() {
    try { return JSON.parse(localStorage.getItem(NP_ONBOARDING_KEY)) || null } catch (e) { return null }
  },
  completed() {
    const s = this.state()
    return !!(s && s.v === 1 && s.done && s.choice)
  },
  choice() {
    const s = this.state()
    return s && s.choice ? s.choice : null
  },
  complete(choice) {
    if (choice !== 'ai' && choice !== 'no_ai') return false
    try {
      localStorage.setItem(NP_ONBOARDING_KEY, JSON.stringify({ v: 1, choice: choice, done: true, at: new Date().toISOString() }))
      return true
    } catch (e) { return false }
  }
}

const npCloseOverlay = (el, choice) => {
  if (choice) window.NpOnboarding.complete(choice)
  if (el && el.npAbortController) el.npAbortController.abort()
  document.body.style.overflow = ''
  const wasResources = el && el.id === 'np-resources'
  if (el && el.parentNode) el.parentNode.removeChild(el)
  if (wasResources) {
    const toggle = document.getElementById('navbarDropdown')
    if (toggle) toggle.focus()
  }
}

// P3 transition: welcome menu "Use AI" -> open Florence (butler dropdown).
const npOpenFlorence = () => {
  const toggle = document.getElementById('navbarDropdown')
  if (!toggle) return
  jQuery(toggle).dropdown('show')
  toggle.focus()
}

// P3: "I hate AI" -> open non-AI resources/tutorial menu (choice already recorded).
const npOpenResources = () => {
  const el = document.getElementById('np-resources')
  if (!el) return
  el.hidden = false
  el.classList.add('is-visible')
  document.body.style.overflow = 'hidden'
  el.focus()
}

// Welcome overlay: server renders it when onboarding may be pending;
// guests additionally check localStorage (server-first for authed, per contract).
$(document).on('turbolinks:load', () => {
  const el = document.getElementById('np-onboarding')
  if (!el || el.hidden === false) return
  if (el.dataset.authed !== '1' && window.NpOnboarding.completed()) {
    npCloseOverlay(el)
    return
  }
  el.hidden = false
  el.classList.add('is-visible')
  document.body.style.overflow = 'hidden'
  const first = el.querySelector('[data-np-choice]')
  if (first) first.focus()
})

$(document).on('click', '#np-onboarding [data-np-choice]', (e) => {
  const el = document.getElementById('np-onboarding')
  if (!el || !document.contains(el)) return
  const choice = e.currentTarget.dataset.npChoice

  if (el.dataset.authed !== '1') {
    npCloseOverlay(el, choice)
    if (choice === 'ai') setTimeout(npOpenFlorence, 0)
    else npOpenResources()
    return
  }

  // Authed: dismissal gated on server ack (server-first contract); on failure
  // keep the overlay open so the choice is not silently lost.
  const errorEl = el.querySelector('.np-onboarding__error')
  const controller = new AbortController()
  el.npAbortController = controller
  fetch('/users/onboarding', {
    method: 'PATCH',
    headers: {
      'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'onboarding_choice=' + encodeURIComponent(choice),
    signal: controller.signal
  }).then((res) => {
    if (!document.contains(el)) return
    if (res.ok) {
      npCloseOverlay(el, choice)
      if (choice === 'ai') setTimeout(npOpenFlorence, 0)
      else npOpenResources()
    } else if (errorEl) errorEl.hidden = false
  }).catch((err) => {
    if (err && err.name === 'AbortError') return
    if (!document.contains(el)) return
    if (errorEl) errorEl.hidden = false
  })
})

// ESC exits without recording (satisfies WCAG 2.1.2 keyboard exit; guest/authed see it again next visit).
$(document).on('keydown', (e) => {
  if (e.key !== 'Escape') return
  const resources = document.getElementById('np-resources')
  if (resources && !resources.hidden) return npCloseOverlay(resources)
  const el = document.getElementById('np-onboarding')
  if (el && !el.hidden) npCloseOverlay(el)
})

// Close button on the resources menu (choice already recorded; just dismiss).
$(document).on('click', '#np-resources [data-np-resources-close]', () => {
  npCloseOverlay(document.getElementById('np-resources'))
})

// Keep focus inside the dialog while it is open.
$(document).on('keydown', '#np-onboarding, #np-resources', (e) => {
  if (e.key !== 'Tab') return
  const el = e.currentTarget
  const focusables = el.querySelectorAll('button, a[href]')
  if (!focusables.length) return
  const first = focusables[0]
  const last = focusables[focusables.length - 1]
  if (!el.contains(document.activeElement)) {
    e.preventDefault()
    first.focus()
  } else if (e.shiftKey && document.activeElement === first) {
    e.preventDefault()
    last.focus()
  } else if (!e.shiftKey && document.activeElement === last) {
    e.preventDefault()
    first.focus()
  }
})
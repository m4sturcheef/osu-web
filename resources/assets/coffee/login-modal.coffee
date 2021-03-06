###
Copyright 2015 ppy Pty. Ltd.

This file is part of osu!web. osu!web is distributed with the hope of
attracting more community contributions to the core ecosystem of osu!.

osu!web is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
###
class LoginModal
  _mobileElements: document.getElementsByClassName('visible-xs')
  box: document.getElementsByClassName('js-login-box')
  activeBox: document.getElementsByClassName('js-login-box--active')
  avatar: document.getElementsByClassName('js-nav-avatar')
  clickAfterLogin: null


  constructor: ->
    $(window).on 'resize scroll', =>
      requestAnimationFrame @reposition

    $(document).on 'show.bs.modal', '#login-modal', @activate
    $(document).on 'hidden.bs.modal', '#login-modal', @deactivate
    $(document).on 'ajax:success', '#login-form', @done

    $(document).on 'click', '.js-login-required--click', (event) =>
      return unless window.user == null
      event.preventDefault()
      @show event.target

    $(document).on 'ajax:error', (event, xhr) =>
      return unless xhr.status == 401
      @show event.target

  _isMobile: =>
    dimensions = @_mobileElements[0].getBoundingClientRect()
    return dimensions.width != 0 && dimensions.height != 0


  isAvatarVisible: =>
    @avatar[0].getBoundingClientRect().bottom > 0


  show: (target) =>
    $('#login-modal').modal 'show'
    @clickAfterLogin = target


  activate: =>
    @box[0].classList.add 'js-login-box--active'
    @reposition()


  deactivate: =>
    @box[0].classList.remove 'js-login-box--active'
    @clickAfterLogin = null


  reposition: =>
    return if @activeBox[0] == undefined

    if @_isMobile()
      @box[0].classList.add 'js-login-centre'
      @box[0].style.marginTop = '60px'

    else if @isAvatarVisible()
      avatarDimensions = @avatar[0].getBoundingClientRect()
      normalTop = avatarDimensions.bottom + 20
      normalRight = window.innerWidth - avatarDimensions.right

      @box[0].classList.remove 'js-login-centre'
      @box[0].style.marginTop = "#{normalTop}px"
      @box[0].style.right = "#{normalRight}px"

    else
      @box[0].classList.add 'js-login-centre'
      @box[0].style.marginTop = '90px'


  done: (_event, data) =>
    window.user = data
    $(document).off 'ajax:complete', osu.hideLoadingOverlay()
    osu.showLoadingOverlay()
    if @clickAfterLogin != null
      if @clickAfterLogin.submit
        # plain javascript here doesn't trigger submit events
        # which means jquery-ujs handler won't be triggered
        # reference: https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/submit
        $(@clickAfterLogin).submit()
      else if @clickAfterLogin.click
        # inversely, using jquery here won't actually click the thing
        # reference: https://github.com/jquery/jquery/blob/f5aa89af7029ae6b9203c2d3e551a8554a0b4b89/src/event.js#L586
        @clickAfterLogin.click()
    else
      osu.reloadPage null, true

    $('#login-modal').modal 'hide'



window.loginModal = new LoginModal


# for pages which require authentication
# and being visited directly from outside
$(document).on 'ready page:load', ->
  return unless window.showLoginModal

  window.showLoginModal = null
  $('#login-modal').modal backdrop: 'static'

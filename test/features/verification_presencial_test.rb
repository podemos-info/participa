require "test_helper"

feature "VerificationPresencial" do

  # FIXME: should initialize on bec
  # Rails.application.secrets.features["verification_presencial"] = true
  # Rails.application.secrets.organization["folder"] = "bec"

  scenario "user should verificate to access tools", js: true do

    # cant access as anon
    page.driver.block_unknown_urls
    visit verification_step1_path
    assert_equal page.current_path, root_path(locale: :es)

    # initialize
    user = FactoryGirl.create(:user)
    election = FactoryGirl.create(:election)

    # should see the pending verification message if isn't verified
    login_as(user)
    visit root_path
    # XXX pasca - esto falla por el idioma??
    #page.must_have_content I18n.t('verification.pending0_html')

    # can't access verification admin
    visit verification_step1_path
    assert_equal page.current_path, root_path(locale: :es)

    # can't access vote
    visit create_vote_path(election_id: election.id)
    #page.must_have_content I18n.t('app.unauthorized')

  end

  scenario "user verifications_admin can verify", js: true do

    # should see the pending verification message if isn't verified
    user2 = FactoryGirl.create(:user)
    login_as(user2)
    visit root_path
    page.driver.block_unknown_urls
# XXX pasca - faltan cosas aqui, no cuadra con el modelo...
=begin
    #page.must_have_content I18n.t('verification.pending0_html')
    logout(user2)
    Capybara.reset_sessions!

    # user1 can verify to user2
    user1 = FactoryGirl.create(:user)
    user1.verifications_admin = true
    user1.save
    login_as(user1)
    visit verification_step1_path
    page.must_have_content I18n.t('verification.form.document')
    check('user_document')
    check('user_town')
    check('user_over_18')
    click_button('Siguiente')
    fill_in(:user_email, with: user2.email)
    click_button('Siguiente')
    page.must_have_content I18n.t('verification.result')
    click_button('Si, estos datos coinciden')
    page.must_have_content I18n.t('verification.alerts.ok.title')
    logout(user1)

    # should see the OK verification message
    login_as(user2)
    visit root_path
    page.must_have_content 'El lugar oficial de encuentro y debate de Podemos'
    logout(user2)
=end
  end

end

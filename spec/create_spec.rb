require_relative 'spec_helper'

describe 'The mock/create page' do
  it 'has all the needed form fields' do
    visit('/mock/create')
    expect(page).to have_field('mock_name')
    expect(page).to have_field('mock_http_status')
    expect(page).to have_field('chk_mock_state', {checked: false})

    expect(page).to have_field('mock_request_url')
    expect(page).to have_button('clone_headers_button')
    expect(page).to have_button('get_button', {disabled: true})

    expect(page).to have_select('sl_mock_http_verb')
    expect(page).to have_select('sl_mock_environment')
    expect(page).to have_select('id_mock_content_type')
    expect(page).to have_field('mock_data_response_headers')

    expect(page).to have_button('advanced_button')

    expect(page).to have_field('mock_data_response')

    expect(page).not_to have_unchecked_field('chk_has_before_script')
    expect(page).not_to have_field('before_script_name')

    expect(page).not_to have_unchecked_field('chk_has_after_script')
    expect(page).not_to have_field('after_script_name')

    expect(page).not_to have_field('mock_cookie')
  end

  it 'shows the advanced options when the show advanced button is clicked' do
    visit('/mock/create')
    click_button('Show Advanced Options')

    expect(page).to have_unchecked_field('chk_has_before_script')
    expect(page).to have_field('before_script_name')

    expect(page).to have_unchecked_field('chk_has_after_script')
    expect(page).to have_field('after_script_name')

    expect(page).to have_field('mock_cookie')
  end

end
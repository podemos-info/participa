require 'spec_helper'

feature 'CardRenewal' do
  it 'card renewal text 1' do

  end

  test "creditcard_error" do
    user =User.find(1)
    email =CollaborationsMailer.creditcard_error_email(user)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['administracion@podemos.info'], email.from
    assert_equal ['ggalancs@yahoo.com'], email.to
    assert_equal 'Problema en el pago con tarjeta de su colaboración', email.subject
    assert_equal read_fixture('creditcard_error').join, email.body.to_s
  end

  test "creditcard_expired" do
    user =User.find(1)
    email =CollaborationsMailer.creditcard_expired_email user
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['administracion@podemos.info'], email.from
    assert_equal ['ggalancs@yahoo.com'], email.to
    assert_equal 'Problema en el pago con tarjeta de su colaboración', email.subject
    assert_equal read_fixture('creditcard_expired').join, email.body.to_s
  end

  test "receipt_returned" do
    user =User.find(1)
    email =CollaborationsMailer.receipt_returned user
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ 'administracion@podemos.info'], email.from
    assert_equal ['ggalancs@yahoo.com'], email.to
    assert_equal 'Problema en la domiciliación del recibo de su colaboración', email.subject
    assert_equal read_fixture('receipt_returned').join, email.body.to_s
  end

  test "receipt_suspended" do
    user =User.find(1)
    email =CollaborationsMailer.receipt_suspended user
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['administracion@podemos.info'], email.from
    assert_equal ['ggalancs@yahoo.com'], email.to
    assert_equal 'Problema en la domicilación de sus recibos, colaboración suspendida temporalmente', email.subject
    assert_equal read_fixture('receipt_suspended').join, email.body.to_s
  end
end

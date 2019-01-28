# Add extra fields to SReg
module OpenID
  module SReg
    DATA_FIELDS.merge!({
      'fullname'=>'Full Name',
      'nickname'=>'Nickname',
      'dob'=>'Date of Birth',
      'email'=>'E-mail Address',
      'gender'=>'Gender',
      'postcode'=>'Postal Code',
      'country'=>'Country',
      'language'=>'Language',
      'timezone'=>'Time Zone',
      'guid' => 'Unique identifier',
      'first_name' => 'First name',
      'last_name' => 'Last name',
      'phone' => 'Phone',
      'remote_id' => 'Remote identifier',
      'address' => 'Address',
      'town' => 'Town',
      'district' => 'District',
      'verified' => 'Verified'
    })
  end
end
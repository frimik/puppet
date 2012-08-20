#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'facter/util/plist'

describe Puppet::Type.type(:user).provider(:osx) do
  let(:resource) do
    Puppet::Type.type(:user).new(
      :name => 'nonexistant_user',
      :provider => :osx
    )
  end

  let(:defaults) do
    {
      'UniqueID'         => '1000',
      'RealName'         => resource[:name],
      'PrimaryGroupID'   => '20',
      'UserShell'        => '/bin/bash',
      'NFSHomeDirectory' => "/Users/#{resource[:name]}"
    }
  end

  let(:user_plist_xml) do
    '<?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
            <key>dsAttrTypeStandard:NFSHomeDirectory</key>
            <array>
            <string>/Users/testuser</string>
            </array>
            <key>dsAttrTypeStandard:RealName</key>
            <array>
            <string>testuser</string>
            </array>
            <key>dsAttrTypeStandard:PrimaryGroupID</key>
            <array>
            <string>22</string>
            </array>
            <key>dsAttrTypeStandard:UniqueID</key>
            <array>
            <string>1000</string>
            </array>
            <key>dsAttrTypeStandard:RecordName</key>
            <array>
            <string>testuser</string>
            </array>
    </dict>
    </plist>'
  end

  let(:user_plist_hash) do
    {
      "dsAttrTypeStandard:RealName"         => ["testuser"],
      "dsAttrTypeStandard:NFSHomeDirectory" => ["/Users/testuser"],
      "dsAttrTypeStandard:PrimaryGroupID"   => ["22"],
      "dsAttrTypeStandard:UniqueID"         => ["1000"],
      "dsAttrTypeStandard:RecordName"       => ["testuser"]
    }
  end

  let(:user_plist_resource) do
    {
      :ensure   => :present,
      :provider => :osx,
      :comment  => 'testuser',
      :name     => 'testuser',
      :uid      => 1000,
      :gid      => 22,
      :home     => '/Users/testuser'
    }
  end

  let(:group_plist_hash) do
    [{
      'dsAttrTypeStandard:RecordName'      => ['testgroup'],
      'dsAttrTypeStandard:GroupMembership' => [
                                                'testuser',
                                                'nonexistant_user',
                                                'jeff',
                                                'zack'
                                              ],
      'dsAttrTypeStandard:GroupMembers'    => [
                                                'guidtestuser',
                                                'guidjeff',
                                                'guidzack'
                                              ],
    },
    {
      'dsAttrTypeStandard:RecordName'      => ['second'],
      'dsAttrTypeStandard:GroupMembership' => [
                                                'nonexistant_user',
                                                'jeff',
                                              ],
      'dsAttrTypeStandard:GroupMembers'    => [
                                                'guidtestuser',
                                                'guidjeff',
                                              ],
    },
    {
      'dsAttrTypeStandard:RecordName'      => ['third'],
      'dsAttrTypeStandard:GroupMembership' => [
                                                'jeff',
                                                'zack'
                                              ],
      'dsAttrTypeStandard:GroupMembers'    => [
                                                'guidjeff',
                                                'guidzack'
                                              ],
    }]
  end

  let(:group_plist_hash_guid) do
    [{
      'dsAttrTypeStandard:RecordName'      => ['testgroup'],
      'dsAttrTypeStandard:GroupMembership' => [
                                                'testuser',
                                                'jeff',
                                                'zack'
                                              ],
      'dsAttrTypeStandard:GroupMembers'    => [
                                                'guidnonexistant_user',
                                                'guidtestuser',
                                                'guidjeff',
                                                'guidzack'
                                              ],
    },
    {
      'dsAttrTypeStandard:RecordName'      => ['second'],
      'dsAttrTypeStandard:GroupMembership' => [
                                                'testuser',
                                                'jeff',
                                                'zack'
                                              ],
      'dsAttrTypeStandard:GroupMembers'    => [
                                                'guidtestuser',
                                                'guidjeff',
                                                'guidzack'
                                              ],
    },
    {
      'dsAttrTypeStandard:RecordName'      => ['third'],
      'dsAttrTypeStandard:GroupMembership' => [
                                                'testuser',
                                                'jeff',
                                                'zack'
                                              ],
      'dsAttrTypeStandard:GroupMembers'    => [
                                                'guidnonexistant_user',
                                                'guidtestuser',
                                                'guidjeff',
                                                'guidzack'
                                              ],
    }]
  end

  let(:empty_plist) do
    '<?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    </dict>
    </plist>'
  end

  let(:sha512_shadowhashdata_plist) do
    '<?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
       <key>dsAttrTypeNative:ShadowHashData</key>
       <array>
         <string>62706c69 73743030 d101025d 53414c54 45442d53 48413531 324f1044 7ea7d592 131f57b2 c8f8bdbc ec8d9df1 2128a386 393a4f00 c7619bac 2622a44d 451419d1 1da512d5 915ab98e 39718ac9 4083fe2e fd6bf710 a54d477f 8ff735b1 2587192d 080b1900 00000000 00010100 00000000 00000300 00000000 00000000 00000000 000060</string>
       </array>
     </dict>
     </plist>'
  end

  let(:sha512_shadowhashdata_hash) do
    {
      'dsAttrTypeNative:ShadowHashData' => ['62706c69 73743030 d101025d 53414c54 45442d53 48413531 324f1044 7ea7d592 131f57b2 c8f8bdbc ec8d9df1 2128a386 393a4f00 c7619bac 2622a44d 451419d1 1da512d5 915ab98e 39718ac9 4083fe2e fd6bf710 a54d477f 8ff735b1 2587192d 080b1900 00000000 00010100 00000000 00000300 00000000 00000000 00000000 000060']
    }
  end

  let(:sha512_embedded_bplist) do
    "bplist00\321\001\002]SALTED-SHA512O\020D~\247\325\222\023\037W\262\310\370\275\274\354\215\235\361!(\243\2069:O\000\307a\233\254&\"\244ME\024\031\321\035\245\022\325\221Z\271\2169q\212\311@\203\376.\375k\367\020\245MG\177\217\3675\261%\207\031-\b\v\031\000\000\000\000\000\000\001\001\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000`"
  end

  let(:sha512_pw_string) do
    "~\247\325\222\023\037W\262\310\370\275\274\354\215\235\361!(\243\2069:O\000\307a\233\254&\"\244ME\024\031\321\035\245\022\325\221Z\271\2169q\212\311@\203\376.\375k\367\020\245MG\177\217\3675\261%\207\031-"
  end

  let(:sha512_embedded_bplist_hash) do
    { 'SALTED-SHA512' => StringIO.new(sha512_pw_string) }
  end

  let(:sha512_password_hash) do
    '7ea7d592131f57b2c8f8bdbcec8d9df12128a386393a4f00c7619bac2622a44d451419d11da512d5915ab98e39718ac94083fe2efd6bf710a54d477f8ff735b12587192d'
  end

  let(:pbkdf2_shadowhashdata_hash) do
    {
      "dsAttrTypeNative:ShadowHashData"=>["62706c69 73743030 d101025f 10145341 4c544544 2d534841 3531322d 50424b44 4632d303 04050607 0857656e 74726f70 79547361 6c745a69 74657261 74696f6e 734f1080 0590ade1 9e6953c1 35ae872a e7761823 5df7d46c 63de7f9a 0fcdf2cd 9e7d85e4 b7ca8681 01235b61 58e05a30 9805ee48 14b027a4 be9c23ec 2926bc81 72269aff ba5c9a59 85e81091 fa689807 6d297f1f aa75fa61 7551ef16 71d75200 55c4a0d9 7b9b9c58 05aa322b aedbcd8e e9c52381 1653ac2e a9e9c8d8 f1ac519a 0f2b595e 4f102093 77c46908 a1c8ac2c 3e45c0d4 4da8ad0f cd85ec5c 14d9a59f fc40c9da 31f0ec11 60b0080b 22293136 41c4e700 00000000 00010100 00000000 00000900 00000000 00000000 00000000 0000ea"]
    }
  end

  let(:pbkdf2_embedded_bplist_hash) do
    {
      'SALTED-SHA512-PBKDF2' => {
        'entropy'    => StringIO.new(pbkdf2_pw_string),
        'salt'       => StringIO.new(pbkdf2_salt_string),
        'iterations' => pbkdf2_iterations_value
      }
    }
  end

  let(:pbkdf2_password_hash) do
    '0590ade19e6953c135ae872ae77618235df7d46c63de7f9a0fcdf2cd9e7d85e4b7ca868101235b6158e05a309805ee4814b027a4be9c23ec2926bc8172269affba5c9a5985e81091fa6898076d297f1faa75fa617551ef1671d7520055c4a0d97b9b9c5805aa322baedbcd8ee9c523811653ac2ea9e9c8d8f1ac519a0f2b595e'
  end

  let(:pbkdf2_embedded_plist) do
    "bplist00\321\001\002_\020\024SALTED-SHA512-PBKDF2\323\003\004\005\006\a\bWentropyTsaltZiterationsO\020\200\005\220\255\341\236iS\3015\256\207*\347v\030#]\367\324lc\336\177\232\017\315\362\315\236}\205\344\267\312\206\201\001#[aX\340Z0\230\005\356H\024\260'\244\276\234#\354)&\274\201r&\232\377\272\\\232Y\205\350\020\221\372h\230\am)\177\037\252u\372auQ\357\026q\327R\000U\304\240\331{\233\234X\005\2522+\256\333\315\216\351\305#\201\026S\254.\251\351\310\330\361\254Q\232\017+Y^O\020 \223w\304i\b\241\310\254,>E\300\324M\250\255\017\315\205\354\\\024\331\245\237\374@\311\3321\360\354\021`\260\b\v\")16A\304\347\000\000\000\000\000\000\001\001\000\000\000\000\000\000\000\t\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\352"
  end

  let(:pbkdf2_pw_string) do
    "\005\220\255\341\236iS\3015\256\207*\347v\030#]\367\324lc\336\177\232\017\315\362\315\236}\205\344\267\312\206\201\001#[aX\340Z0\230\005\356H\024\260'\244\276\234#\354)&\274\201r&\232\377\272\\\232Y\205\350\020\221\372h\230\am)\177\037\252u\372auQ\357\026q\327R\000U\304\240\331{\233\234X\005\2522+\256\333\315\216\351\305#\201\026S\254.\251\351\310\330\361\254Q\232\017+Y^"
  end

  let(:pbkdf2_salt_string) do
    "\223w\304i\b\241\310\254,>E\300\324M\250\255\017\315\205\354\\\024\331\245\237\374@\311\3321\360\354"
  end

  let(:pbkdf2_salt_value) do
    "9377c46908a1c8ac2c3e45c0d44da8ad0fcd85ec5c14d9a59ffc40c9da31f0ec"
  end

  let(:pbkdf2_iterations_value) do
    24752
  end

  let(:groups_xml) do
    '<?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <array>
       <dict>
         <key>dsAttrTypeStandard:AppleMetaNodeLocation</key>
         <array>
           <string>/Local/Default</string>
         </array>
         <key>dsAttrTypeStandard:GeneratedUID</key>
         <array>
           <string>ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000053</string>
         </array>
         <key>dsAttrTypeStandard:Password</key>
         <array>
           <string>*</string>
         </array>
         <key>dsAttrTypeStandard:PrimaryGroupID</key>
         <array>
           <string>83</string>
         </array>
         <key>dsAttrTypeStandard:RealName</key>
         <array>
           <string>SPAM Assassin Group 2</string>
         </array>
         <key>dsAttrTypeStandard:RecordName</key>
         <array>
           <string>_amavisd</string>
           <string>amavisd</string>
         </array>
         <key>dsAttrTypeStandard:RecordType</key>
         <array>
           <string>dsRecTypeStandard:Groups</string>
         </array>
       </dict>
      </array>
    </plist>'
  end

  let(:groups_hash) do
    [{ 'dsAttrTypeStandard:AppleMetaNodeLocation' => ['/Local/Default'],
         'dsAttrTypeStandard:GeneratedUID'          => ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000053'],
         'dsAttrTypeStandard:Password'              => ['*'],
         'dsAttrTypeStandard:PrimaryGroupID'        => ['83'],
         'dsAttrTypeStandard:RealName'              => ['SPAM Assassin Group 2'],
         'dsAttrTypeStandard:RecordName'            => ['_amavisd', 'amavisd'],
         'dsAttrTypeStandard:RecordType'            => ['dsRecTypeStandard:Groups']
      }]
  end

  let(:user_guid_xml) do
    '<?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
       <key>dsAttrTypeStandard:GeneratedUID</key>
       <array>
         <string>DCC660C6-F5A9-446D-B9FF-3C0258AB5BA0</string>
       </array>
     </dict>
     </plist>'
  end

  let(:user_guid_hash) do
    { 'dsAttrTypeStandard:GeneratedUID' => ['DCC660C6-F5A9-446D-B9FF-3C0258AB5BA0'] }
  end

  let(:provider) { resource.provider }

  describe '#create with defaults' do
    before :each do
      provider.expects(:dscl).with('.', '-create', "/Users/#{resource[:name]}").returns true
      provider.expects(:next_system_id).returns(defaults['UniqueID'])
      defaults.each do |key,val|
        provider.expects(:dscl).with('.', '-merge', "/Users/#{resource[:name]}", key, val)
      end
    end

    it 'should create a user with defaults given a minimal declaration' do
      provider.create
    end

    it 'should call #password= if a password attribute is specified' do
      resource[:password] = 'somepass'
      provider.expects(:password=).with('somepass')
      provider.create
    end

    #it 'should call #groups= if a groups attribute is specified' do
    #  resource[:groups] = 'groups'
    #  provider.expects(:groups=).with('some,groups')
    #  provider.create
    #end
  end

  describe 'self#instances' do
    it 'should create an array of provider instances' do
      provider.class.expects(:get_all_users).returns(['foo', 'bar'])
      ['foo', 'bar'].each do |user|
        provider.class.expects(:generate_attribute_hash).with(user).returns({})
      end
      provider.class.instances.size.should == 2
    end
  end

  describe 'self#get_all_users' do
    it 'should return a hash of user attributes' do
      provider.class.expects(:dscl).with('-plist', '.', 'readall', '/Users').returns(user_plist_xml)
      provider.class.get_all_users.should == user_plist_hash
    end

    it 'should return a hash when passed an empty plist' do
      provider.class.expects(:dscl).with('-plist', '.', 'readall', '/Users').returns(empty_plist)
      provider.class.get_all_users.should == {}
    end
  end

  describe 'self#generate_attribute_hash' do
    it 'should return :uid values as a Fixnum' do
      provider.class.generate_attribute_hash(user_plist_hash)[:uid].class.should == Fixnum
    end

    it 'should return :gid values as a Fixnum' do
      provider.class.generate_attribute_hash(user_plist_hash)[:gid].class.should == Fixnum
    end

    it 'should return a hash of resource attributes' do
      provider.class.generate_attribute_hash(user_plist_hash).should == user_plist_resource
    end
  end

  describe '#exists?' do
    # This test expects an error to be raised
    # I'm PROBABLY doing this wrong...
    it 'should return false if the dscl command errors out' do
      provider.exists?.should == false
    end

    it 'should return true if the dscl command does not error' do
      provider.expects(:dscl).with('.', 'read', "/Users/#{resource[:name]}").returns(user_plist_xml)
      provider.exists?.should == true
    end
  end

  describe '#delete' do
    it 'should call dscl when destroying/deleting a resource' do
      provider.expects(:dscl).with('.', '-delete', "/Users/#{resource[:name]}")
      provider.delete
    end
  end

  describe '#groups' do
    it "should return a list of groups if the user's name matches GroupMembership" do
      provider.expects(:get_list_of_groups).returns(group_plist_hash)
      provider.expects(:get_attribute_from_dscl).with('Users', 'GeneratedUID').returns(['guidnonexistant_user'])
      provider.groups.should == 'second,testgroup'
    end

    it "should return a list of groups if the user's GUID matches GroupMembers" do
      provider.expects(:get_list_of_groups).returns(group_plist_hash_guid)
      provider.expects(:get_attribute_from_dscl).with('Users', 'GeneratedUID').returns(['guidnonexistant_user'])
      provider.groups.should == 'testgroup,third'
    end
  end

  describe '#groups=' do
    it 'should call dscl to add necessary groups' do
      provider.expects(:groups).returns('two,three')
      provider.expects(:get_attribute_from_dscl).with('Users', 'GeneratedUID').returns({'dsAttrTypeStandard:GeneratedUID' => ['guidnonexistant_user']})
      provider.expects(:dscl).with('.', '-merge', '/Groups/one', 'GroupMembership', 'nonexistant_user')
      provider.expects(:dscl).with('.', '-merge', '/Groups/one', 'GroupMembers', 'guidnonexistant_user')
      provider.groups= 'one,two,three'
    end
  end

  describe '#password' do
    ['10.5', '10.6'].each do |os_ver|
      it "should call the get_sha1 method on #{os_ver}" do
        Facter.expects(:value).with(:macosx_productversion_major).returns(os_ver)
        provider.expects(:get_attribute_from_dscl).with('Users', 'GeneratedUID').returns({'dsAttrTypeStandard:GeneratedUID' => ['guidnonexistant_user']})
        provider.expects(:get_sha1).with('guidnonexistant_user').returns('password')
        provider.password.should == 'password'
      end
    end

    it 'should call the get_salted_sha512 method on 10.7 and return the correct hash' do
      Facter.expects(:value).with(:macosx_productversion_major).returns('10.7')
      provider.expects(:get_attribute_from_dscl).with('Users', 'ShadowHashData').returns(sha512_shadowhashdata_hash)
      provider.password.should == sha512_password_hash
    end

    it 'should call the get_salted_sha512_pbkdf2 method on 10.8 and return the correct hash' do
      Facter.expects(:value).with(:macosx_productversion_major).returns('10.8')
      provider.expects(:get_attribute_from_dscl).with('Users', 'ShadowHashData').returns(pbkdf2_shadowhashdata_hash)
      provider.password.should == pbkdf2_password_hash
    end

  end

  describe '#password=' do
    ['10.5', '10.6'].each do |os_ver|
      it "should call write_sha1_hash when setting the password on #{os_ver}" do
        Facter.expects(:value).with(:macosx_productversion_major).returns(os_ver)
        provider.expects(:write_sha1_hash).with('password')
        provider.password = 'password'
      end
    end

    it 'should call write_password_to_users_plist when setting the password on 10.7' do
      Facter.expects(:value).with(:macosx_productversion_major).twice.returns('10.7')
      provider.expects(:write_password_to_users_plist).with(sha512_password_hash)
      provider.password = sha512_password_hash
    end

    it 'should call write_password_to_users_plist when setting the password on 10.8' do
      Facter.expects(:value).with(:macosx_productversion_major).twice.returns('10.8')
      provider.expects(:write_password_to_users_plist).with(pbkdf2_password_hash)
      provider.password = pbkdf2_password_hash
    end

    it "should raise an error on 10.7 if a password hash that doesn't contain 136 characters is passed" do
      Facter.expects(:value).with(:macosx_productversion_major).twice.returns('10.7')
      expect { provider.password = 'password' }.to raise_error Puppet::Error, /OS X 10\.7 requires a Salted SHA512 hash password of 136 characters\.  Please check your password and try again/
    end

    it "should raise an error on 10.8 if a password hash that doesn't contain 256 characters is passed" do
      Facter.expects(:value).with(:macosx_productversion_major).twice.returns('10.8')
      expect { provider.password = 'password' }.to raise_error Puppet::Error, /OS X versions > 10\.7 require a Salted SHA512 PBKDF2 password hash of 256 characters\. Please check your password and try again\./
    end
  end

  describe '#get_list_of_groups' do
    it 'should return a array of hashes containing group data' do
      provider.expects(:dscl).with('-plist', '.', 'readall', '/Groups').returns(groups_xml)
      provider.get_list_of_groups.should == groups_hash
    end
  end

  describe '#get_attribute_from_dscl' do
    it 'should return a hash containing a user\'s dscl attribute data' do
      provider.expects(:dscl).with('-plist', '.', 'read', '/Users/nonexistant_user', 'GeneratedUID').returns(user_guid_xml)
      provider.get_attribute_from_dscl('Users', 'GeneratedUID').should == user_guid_hash
    end
  end

  describe '#get_embedded_binary_plist' do
    it "should return a hash containing the Salted-SHA512 Password from a user's ShadowHashData dscl key in 10.7" do
      hash_data = provider.get_embedded_binary_plist(sha512_shadowhashdata_hash)

      # We are checking that the returned hash is structured correctly
      # and that the value of the StringIO object match.
      hash_data.keys.should == ['SALTED-SHA512']
      hash_data['SALTED-SHA512'].string.should == sha512_pw_string
    end

    it "should return a hash containing the PBKDF2 password hash, iterations value, and salt value from a user's ShadowHashData dscl key in 10.8" do
      hash_data = provider.get_embedded_binary_plist(pbkdf2_shadowhashdata_hash)

      # We are checking that the returned hash is structured correctly
      # and that the values of the objects match.
      hash_data.keys.should == ['SALTED-SHA512-PBKDF2']
      hash_data['SALTED-SHA512-PBKDF2'].keys.sort.should == ['entropy', 'iterations', 'salt']
      hash_data['SALTED-SHA512-PBKDF2']['salt'].string.should == pbkdf2_salt_string
      hash_data['SALTED-SHA512-PBKDF2']['entropy'].string.should == pbkdf2_pw_string
      hash_data['SALTED-SHA512-PBKDF2']['iterations'].should == pbkdf2_iterations_value
    end
  end

  describe '#convert_xml_to_binary' do
    # Because this method relies on a binary that only exists on OS X, a stub
    # object is needed to expect the calls. This makes testing somewhat...uneventful
    let(:stub_io_object) { stub('connection') }

    it 'should use plutil to successfully convert an xml plist to a binary plist' do
      IO.expects(:popen).with('plutil -convert binary1 -o - -', 'r+').yields stub_io_object
      Plist::Emit.expects(:dump).with('ruby_hash').returns('xml_plist_data')
      stub_io_object.expects(:write).with('xml_plist_data')
      stub_io_object.expects(:close_write)
      stub_io_object.expects(:read).returns('binary_plist_data')
      provider.convert_xml_to_binary('ruby_hash').should == 'binary_plist_data'
    end
  end

  describe '#convert_binary_to_xml' do
    let(:stub_io_object) { stub('connection') }

    it 'should accept a binary plist and return a ruby hash containing the plist data' do
      IO.expects(:popen).with('plutil -convert xml1 -o - -', 'r+').yields stub_io_object
      stub_io_object.expects(:write).with('binary_plist_data')
      stub_io_object.expects(:close_write)
      stub_io_object.expects(:read).returns(user_plist_xml)
      provider.convert_binary_to_xml('binary_plist_data').should == user_plist_hash
    end
  end

  describe '#next_system_id' do
    it 'should return the next available UID number that is not in the list obtained from dscl and is greater than the passed integer value' do
      provider.expects(:dscl).with('.', '-list', '/Users', 'uid').returns("kathee 312\ngary 11\ntanny 33\njohn 9\nzach 5")
      provider.next_system_id(30).should == 34
    end
  end

  describe '#get_salted_sha512' do
    it "should accept a hash whose 'SALTED-SHA512' key contains a StringIO object with a base64 encoded salted-SHA512 password hash and return the hex value of that password hash" do
      provider.get_salted_sha512(sha512_embedded_bplist_hash).should == sha512_password_hash
    end
  end

  describe '#get_salted_sha512_pbkdf2' do
    it "should accept a hash containing a PBKDF2 password hash, salt, and iterations value and return the correct password hash" do
        provider.get_salted_sha512_pbkdf2('entropy', pbkdf2_embedded_bplist_hash).should == pbkdf2_password_hash
    end
    it "should accept a hash containing a PBKDF2 password hash, salt, and iterations value and return the correct salt value" do
        provider.get_salted_sha512_pbkdf2('salt', pbkdf2_embedded_bplist_hash).should == pbkdf2_salt_value
    end
    it "should accept a hash containing a PBKDF2 password hash, salt, and iterations value and return the correct iterations value" do
        provider.get_salted_sha512_pbkdf2('iterations', pbkdf2_embedded_bplist_hash).should == pbkdf2_iterations_value
    end
    it "should return a Fixnum value when looking up the PBKDF2 iterations value" do
        provider.get_salted_sha512_pbkdf2('iterations', pbkdf2_embedded_bplist_hash).class.should == Fixnum
    end
    it "should raise an error if a field other than 'entropy', 'salt', or 'iterations' is passed" do
      expect { provider.get_salted_sha512_pbkdf2('othervalue', pbkdf2_embedded_bplist_hash) }.to raise_error Puppet::Error, /Puppet has tried to read an incorrect value from the SALTED-SHA512-PBKDF2 hash. Acceptable fields are 'salt', 'entropy', or 'iterations'/
    end
  end

  describe '#get_sha1' do
    let(:password_hash_file) { '/var/db/shadow/hash/user_guid' }
    let(:stub_password_file) { stub('connection') }

    it 'should return a a sha1 hash read from disk' do
      File.expects(:exists?).with(password_hash_file).returns(true)
      File.expects(:file?).with(password_hash_file).returns(true)
      File.expects(:readable?).with(password_hash_file).returns(true)
      File.expects(:new).with(password_hash_file).returns(stub_password_file)
      stub_password_file.expects(:read).returns('sha1_password_hash')
      stub_password_file.expects(:close)
      provider.get_sha1('user_guid').should == 'sha1_password_hash'
    end

    it 'should return nil if the password_hash_file does not exist' do
      File.expects(:exists?).with(password_hash_file).returns(false)
      provider.get_sha1('user_guid').should == nil
    end

    it 'should return nil if the password_hash_file is not a file' do
      File.expects(:exists?).with(password_hash_file).returns(true)
      File.expects(:file?).with(password_hash_file).returns(false)
      provider.get_sha1('user_guid').should == nil
    end

    it 'should raise an error if the password_hash_file is not readable' do
      File.expects(:exists?).with(password_hash_file).returns(true)
      File.expects(:file?).with(password_hash_file).returns(true)
      File.expects(:readable?).with(password_hash_file).returns(false)
      expect { provider.get_sha1('user_guid').should == nil }.to raise_error Puppet::Error, /Could not read password hash file at #{password_hash_file}/
    end
  end

  describe '#write_password_to_users_plist' do
    let(:sha512_plist_xml) do
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>KerberosKeys</key>\n\t<array>\n\t\t<data>\n\t\tMIIBS6EDAgEBoIIBQjCCAT4wcKErMCmgAwIBEqEiBCCS/0Im7BAps/YhX/ED\n\t\tKOpDeSMFkUsu3UzEa6gqDu35BKJBMD+gAwIBA6E4BDZMS0RDOlNIQTEuNDM4\n\t\tM0UxNTJEOUQzOTRBQTMyRDEzQUU5OEY2RjZFMUZFOEQwMEY4MWplZmYwYKEb\n\t\tMBmgAwIBEaESBBAk8a3rrFk5mHAdEU5nRgFwokEwP6ADAgEDoTgENkxLREM6\n\t\tU0hBMS40MzgzRTE1MkQ5RDM5NEFBMzJEMTNBRTk4RjZGNkUxRkU4RDAwRjgx\n\t\tamVmZjBooSMwIaADAgEQoRoEGFg71irsV+9ddRNPSn9houo3Q6jZuj55XaJB\n\t\tMD+gAwIBA6E4BDZMS0RDOlNIQTEuNDM4M0UxNTJEOUQzOTRBQTMyRDEzQUU5\n\t\tOEY2RjZFMUZFOEQwMEY4MWplZmY=\n\t\t</data>\n\t</array>\n\t<key>ShadowHashData</key>\n\t<array>\n\t\t<data>\n\t\tYnBsaXN0MDDRAQJdU0FMVEVELVNIQTUxMk8QRFNL0iuruijP6becUWe43GTX\n\t\t5WTgOTi2emx41DMnwnB4vbKieVOE4eNHiyocX5c0GX1LWJ6VlZqZ9EnDLsuA\n\t\tNC5Ga9qlCAsZAAAAAAAAAQEAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAGA=\n\t\t</data>\n\t</array>\n\t<key>authentication_authority</key>\n\t<array>\n\t\t<string>;Kerberosv5;;jeff@LKDC:SHA1.4383E152D9D394AA32D13AE98F6F6E1FE8D00F81;LKDC:SHA1.4383E152D9D394AA32D13AE98F6F6E1FE8D00F81</string>\n\t\t<string>;ShadowHash;HASHLIST:&lt;SALTED-SHA512&gt;</string>\n\t</array>\n\t<key>dsAttrTypeStandard:ShadowHashData</key>\n\t<array>\n\t\t<data>\n\t\tYnBsaXN0MDDRAQJdU0FMVEVELVNIQTUxMk8QRH6n1ZITH1eyyPi9vOyNnfEh\n\t\tKKOGOTpPAMdhm6wmIqRNRRQZ0R2lEtWRWrmOOXGKyUCD/i79a/cQpU1Hf4/3\n\t\tNbElhxktCAsZAAAAAAAAAQEAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAGA=\n\t\t</data>\n\t</array>\n\t<key>generateduid</key>\n\t<array>\n\t\t<string>3AC74939-C14F-45DD-B6A9-D1A82373F0B0</string>\n\t</array>\n\t<key>name</key>\n\t<array>\n\t\t<string>jeff</string>\n\t</array>\n\t<key>passwd</key>\n\t<array>\n\t\t<string>********</string>\n\t</array>\n\t<key>passwordpolicyoptions</key>\n\t<array>\n\t\t<data>\n\t\tPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NU\n\t\tWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VO\n\t\tIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4w\n\t\tLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdD4KCTxrZXk+ZmFp\n\t\tbGVkTG9naW5Db3VudDwva2V5PgoJPGludGVnZXI+MDwvaW50ZWdlcj4KCTxr\n\t\tZXk+ZmFpbGVkTG9naW5UaW1lc3RhbXA8L2tleT4KCTxkYXRlPjIwMDEtMDEt\n\t\tMDFUMDA6MDA6MDBaPC9kYXRlPgoJPGtleT5sYXN0TG9naW5UaW1lc3RhbXA8\n\t\tL2tleT4KCTxkYXRlPjIwMDEtMDEtMDFUMDA6MDA6MDBaPC9kYXRlPgoJPGtl\n\t\teT5wYXNzd29yZFRpbWVzdGFtcDwva2V5PgoJPGRhdGU+MjAxMi0wOC0xMVQw\n\t\tMDozNTo1MFo8L2RhdGU+CjwvZGljdD4KPC9wbGlzdD4K\n\t\t</data>\n\t</array>\n\t<key>uid</key>\n\t<array>\n\t\t<string>28</string>\n\t</array>\n</dict>\n</plist>"
    end

    let(:pbkdf2_plist_xml) do
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>KerberosKeys</key>\n\t<array>\n\t\t<data>\n\t\tMIIBS6EDAgEBoIIBQjCCAT4wcKErMCmgAwIBEqEiBCDrboPy0gxu7oTZR/Pc\n\t\tYdCBC9ivXo1k05gt036/aNe5VqJBMD+gAwIBA6E4BDZMS0RDOlNIQTEuNDEz\n\t\tQTMwRjU5MEVFREM3ODdENTMyOTgxODUwQTk3NTI0NUIwQTcyM2plZmYwYKEb\n\t\tMBmgAwIBEaESBBCm02SYYdsxo2fiDP4KuPtmokEwP6ADAgEDoTgENkxLREM6\n\t\tU0hBMS40MTNBMzBGNTkwRUVEQzc4N0Q1MzI5ODE4NTBBOTc1MjQ1QjBBNzIz\n\t\tamVmZjBooSMwIaADAgEQoRoEGHPBc7Dg7zjaE8g+YXObwupiBLMIlCrN5aJB\n\t\tMD+gAwIBA6E4BDZMS0RDOlNIQTEuNDEzQTMwRjU5MEVFREM3ODdENTMyOTgx\n\t\tODUwQTk3NTI0NUIwQTcyM2plZmY=\n\t\t</data>\n\t</array>\n\t<key>ShadowHashData</key>\n\t<array>\n\t\t<data>\n\t\tYnBsaXN0MDDRAQJfEBRTQUxURUQtU0hBNTEyLVBCS0RGMtMDBAUGBwhXZW50\n\t\tcm9weVRzYWx0Wml0ZXJhdGlvbnNPEIAFkK3hnmlTwTWuhyrndhgjXffUbGPe\n\t\tf5oPzfLNnn2F5LfKhoEBI1thWOBaMJgF7kgUsCekvpwj7CkmvIFyJpr/ulya\n\t\tWYXoEJH6aJgHbSl/H6p1+mF1Ue8WcddSAFXEoNl7m5xYBaoyK67bzY7pxSOB\n\t\tFlOsLqnpyNjxrFGaDytZXk8QIJN3xGkIocisLD5FwNRNqK0PzYXsXBTZpZ/8\n\t\tQMnaMfDsEWCwCAsiKTE2QcTnAAAAAAAAAQEAAAAAAAAACQAAAAAAAAAAAAAA\n\t\tAAAAAOo=\n\t\t</data>\n\t</array>\n\t<key>authentication_authority</key>\n\t<array>\n\t\t<string>;Kerberosv5;;jeff@LKDC:SHA1.413A30F590EEDC787D532981850A975245B0A723;LKDC:SHA1.413A30F590EEDC787D532981850A975245B0A723</string>\n\t\t<string>;ShadowHash;HASHLIST:&lt;SALTED-SHA512-PBKDF2&gt;</string>\n\t</array>\n\t<key>generateduid</key>\n\t<array>\n\t\t<string>1CB825D1-2DF7-43CC-B874-DB6BBB76C402</string>\n\t</array>\n\t<key>gid</key>\n\t<array>\n\t\t<string>21</string>\n\t</array>\n\t<key>name</key>\n\t<array>\n\t\t<string>jeff</string>\n\t</array>\n\t<key>passwd</key>\n\t<array>\n\t\t<string>********</string>\n\t</array>\n\t<key>passwordpolicyoptions</key>\n\t<array>\n\t\t<data>\n\t\tPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NU\n\t\tWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VO\n\t\tIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4w\n\t\tLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdD4KCTxrZXk+ZmFp\n\t\tbGVkTG9naW5Db3VudDwva2V5PgoJPGludGVnZXI+MDwvaW50ZWdlcj4KCTxr\n\t\tZXk+ZmFpbGVkTG9naW5UaW1lc3RhbXA8L2tleT4KCTxkYXRlPjIwMDEtMDEt\n\t\tMDFUMDA6MDA6MDBaPC9kYXRlPgoJPGtleT5sYXN0TG9naW5UaW1lc3RhbXA8\n\t\tL2tleT4KCTxkYXRlPjIwMDEtMDEtMDFUMDA6MDA6MDBaPC9kYXRlPgoJPGtl\n\t\teT5wYXNzd29yZExhc3RTZXRUaW1lPC9rZXk+Cgk8ZGF0ZT4yMDEyLTA3LTI1\n\t\tVDE4OjQ3OjU5WjwvZGF0ZT4KPC9kaWN0Pgo8L3BsaXN0Pgo=\n\t\t</data>\n\t</array>\n\t<key>uid</key>\n\t<array>\n\t\t<string>28</string>\n\t</array>\n</dict>\n</plist>"
    end

    let(:sha512_shadowhashdata) do
      {
        'SALTED-SHA512' => StringIO.new('blankvalue')
      }
    end

    let(:pbkdf2_shadowhashdata) do
      {
        'SALTED-SHA512-PBKDF2' => {
          'entropy'    => StringIO.new('blank_entropy'),
          'salt'       => StringIO.new('blank_salt'),
          'iterations' => 100
        }
      }
    end

    let(:users_plist_dir) { '/var/db/dslocal/nodes/Default/users' }
    let(:stub_shadowhashdata) { stub('connection') }

    it 'should call set_salted_sha512 on 10.7 when given a a salted-SHA512 password hash' do
      provider.expects(:plutil).with('-convert', 'xml1', '-o', '/dev/stdout', "#{users_plist_dir}/nonexistant_user.plist").returns(sha512_plist_xml)
      Facter.expects(:value).with(:macosx_productversion_major).returns('10.7')
      # The below line is not as tight as I would like. It would be
      # nice to set the expectation using .with and passing the hash
      # we're expecting, but there are several StringIO objects that
      # report with a hex identifier. Even though the string data
      # matches, frequently the hex identifiers vary slightly. I
      # feel like the work I'd need to do to keep the StringIO objects
      # in sync would result in a test with staged data.
      provider.expects(:set_salted_sha512)
      provider.write_password_to_users_plist(sha512_password_hash)
    end

    it 'should call set_salted_pbkdf2 on 10.8 when given a PBKDF2 password hash' do
      provider.expects(:plutil).with('-convert', 'xml1', '-o', '/dev/stdout', "#{users_plist_dir}/nonexistant_user.plist").returns(pbkdf2_plist_xml)
      Facter.expects(:value).with(:macosx_productversion_major).returns('10.8')
      # See comment in previous test...
      provider.expects(:set_salted_pbkdf2)
      provider.write_password_to_users_plist(pbkdf2_password_hash)
    end

    it "should delete the SALTED-SHA512 key in the shadow_hash_data hash if it exists on a 10.8 system and write_password_to_users_plist has been called to set the user's password" do
      provider.expects(:plutil).with('-convert', 'xml1', '-o', '/dev/stdout', "#{users_plist_dir}/nonexistant_user.plist").returns('xml_data')
      Plist.expects(:parse_xml).with('xml_data').returns('ruby_hash')
      Facter.expects(:value).with(:macosx_productversion_major).returns('10.8')
      provider.expects(:get_shadow_hash_data).with('ruby_hash').returns(stub_shadowhashdata)
      stub_shadowhashdata.expects(:[]).with('SALTED-SHA512').returns(true)
      stub_shadowhashdata.expects(:delete).with('SALTED-SHA512')
      provider.expects(:set_salted_pbkdf2).with('ruby_hash', stub_shadowhashdata, pbkdf2_password_hash)
      provider.write_password_to_users_plist(pbkdf2_password_hash)
    end
  end

  describe '#get_shadow_hash_data' do
    let(:sha512_users_plist) do
      {
        'ShadowHashData' => [StringIO.new(sha512_embedded_bplist)]
      }
    end

    it "should return a hash containing the keys and values within the binary plist embedded in the ShadowHashData key of the user's plist if it exist" do
      result = provider.get_shadow_hash_data(sha512_users_plist)
      result.keys.should == ['SALTED-SHA512']
      result['SALTED-SHA512'].string.should == sha512_pw_string
    end

    it 'should return false if the passed users_plist does not contain a ShadowHashData key' do
      provider.get_shadow_hash_data(Hash.new).should == false
    end
  end
end
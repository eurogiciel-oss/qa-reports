require 'csv'

def find_feature_row (feature_name)
  feature_name_cell = find(".feature_record a", :text => feature_name) # Locate the feature title cell
  feature_name_cell.find(:xpath, "ancestor::tr[contains(@class, 'feature_record')]") # Locate the parent feature row
end

Then %r/^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

Then %r/^I should see the main navigation columns$/ do
  step %{I should see "Core" within "#report_navigation"}
  step %{I should see "Handset" within "#report_navigation"}
  step %{I should see "Netbook" within "#report_navigation"}
  step %{I should see "IVI" within "#report_navigation"}
end

When %r/^I should see the sign in link without ability to add report$/ do
  step %{I should see "Sign In"}
  step %{I should not see "Add report"}
end

When %r/I view the group report "([^"]*)"$/ do |report_string|
  visit("/#{report_string}")
end

Then %r/^I should see the download link for the result file "([^"]*)"$/ do |result_file|
  with_scope('#result_file_drag_drop_area .file_list_ready') do
    find_link(result_file)
  end
end

When %r/^I download the exported group CSV for "([^"]*)"$/ do |report_uri|
  response = get "/#{report_uri}/csv"
  @csv_str = response.body
end

When %r/^I download the exported report CSV for "([^"]*)"$/ do |report_string|
  release, profile, testset, product = report_string.split('/')
  report = MeegoTestSession.release(release).profile(profile).testset(testset).product_is(product).last
  raise "report not found with parameters #{release}/#{profile}/#{testset}/#{product}!" unless report
  response = get "#{show_report_path(release, profile, testset, product, report)}/download"
  @csv_str = response.body
end

Then %r/I should see the imported data from "([^"]*)" and "([^"]*)" in the exported CSV.$/ do |file1, file2|
  input = CSV.read('features/resources/' + file1).drop(1) +
          CSV.read('features/resources/' + file2).drop(1)
  expected = input.each{|list| list.insert(4, "0")} # Add Measured result value. It is generated in export even if not given in import
  # Not using page.text anymore because of
  # https://github.com/jnicklas/capybara/issues/952
  result = CSV.parse(@csv_str, {:col_sep => ';'}).drop(1)
  actual = result.map{ |item| (6..12).map{|field| item[field]}}

  actual.count.should == expected.count

  difference = actual - expected
  difference.should be_empty, "Exported data does not match with the imported\nExpected: #{expected.to_yaml}\nGot: #{actual.to_yaml}\n"
end

Then %r/I should see the imported test cases from "([^"]*)" in the exported CSV.$/ do |file|
  input = CSV.read('features/resources/' + file).drop(1)
  expected = input.each{|list| list.insert(5, nil)} # Add Measured result value. It is generated in export even if not given in import
  # Not using page.text anymore because of
  # https://github.com/jnicklas/capybara/issues/952
  result = CSV.parse(@csv_str, {:col_sep => ','}).drop(1)
  actual = result.map{ |item| (0..6).map{|field| item[field]}}
  actual.count.should == expected.count
  difference = actual - expected
  difference.should be_empty, "Exported data does not match with the imported\nExpected: #{expected.to_yaml}\nGot: #{actual.to_yaml}\n"
end

When %r/^(?:|I )(?:|return to )view the report "([^"]*)"$/ do |report_string|
  release, profile, testset, product = report_string.split('/')
  report = MeegoTestSession.release(release).profile(profile).testset(testset).product_is(product).last
  raise "report not found with parameters #{release}/#{profile}/#{testset}/#{product}!" unless report
  visit show_report_path(release, profile, testset, product, report)
end

When %r/I view the report "([^"]*)" for build$/ do |report_string|
  release, profile, testset, product = report_string.split('/')
  report = MeegoTestSession.first(:conditions =>
    {"releases.name" => release, "profiles.name" => profile, :product => product, :testset => testset}, :include => [:release, :profile],
    :order => "build_id DESC, tested_at DESC, created_at DESC")
  raise "report not found with parameters #{release}/#{profile}/#{testset}/#{product}!" unless report
  visit show_report_path(release, profile, testset, product, report)
end

Given %r/^I have created the "([^"]*)" report(?: using "([^"]*)")?(?: and optional build id is "([^"]*)")?$/ do |report_name, report_template, build_id|
  step %{I have created the "#{report_name}" report with date "2010-02-02" using "#{report_template}" and optional build id is "#{build_id}"}
end

Given %r/^I have created the "([^"]*)" report with date "([^"]*)"(?: using "([^"]*)")?(?: and optional build id is "([^"]*)")?$/ do |report_name, report_date, report_template, build_id|
  version, target, test_set, product = report_name.split('/')

  if not report_template.present?
    report_template = "sample.csv"
  end

  step "I am on the front page"
  step %{I follow "Add report"}
  step %{I fill in "report_test_execution_date" with "#{report_date}"}
  step %{I choose "#{version}"}
  step %{I select target "#{target}", test set "#{test_set}" and product "#{product}"}
  step %{I select build id "#{build_id}"}
  step %{I attach the report "#{report_template}"}
  step %{I submit the form at "upload_report_submit"}
  step %{I submit the form at "upload_report_submit"}
end

Given %r/^there exists a report for "([^"]*)"$/ do |report_name|
  version, target, test_set, product = report_name.split('/')

  fpath    = File.join(Rails.root, "features", "resources", "sample.csv")
  testfile = File.new(fpath)

  user = User.create!(:name => "John Longbottom",
    :email => "email@email.com",
    :password => "password",
    :password_confirmation => "password")

  session = MeegoTestSession.new(:product => product,
    :testset => test_set, :result_files_attributes => [{:file => testfile}],
    :tested_at => Time.now, :author => user, :editor => user, :release_version => version
  )
  session.profile = Profile.find_by_name(target)
  session.generate_defaults! # Is this necessary, or could we just say create! above?
  session.save!
end


When %r/^I click to edit the report$/ do
  step "I follow \"edit-button\" within \"#edit_report\""
end

When %r/^I click to print the report$/ do
  step "I follow \"print-button\" within \"#edit_report\""
end

When %r/^I click to delete the report$/ do
  step "I follow \"delete-button\" within \"#edit_report\""
end

And %r/there should not be a test case "([^"]*)"$/ do |testcase|
  step %{I should not see "#{testcase}"}
end

When %r/^(?:|I )should see "([^"]*)" within the test case "([^"]*)"$/ do |text, test_case|
  within(:xpath, "//tr[contains(.,'#{test_case}')]") do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

When %r/^(?:|I )submit the comment for the test case "([^"]*)"$/ do |test_case|
  step "I click the element \".small_btn\" for the test case \"#{test_case}\""
end

When %r/^(?:|I )attach the file "([^"]*)" to test case "([^"]*)"$/ do |file, test_case|
  within(:xpath, "//tr[contains(.,'#{test_case}')]") do
    step "attach the file \"#{Dir.getwd}/features/resources/#{file}\" to \"testcase_attachment\""
  end

  step "I submit the comment for the test case \"#{test_case}\""
end

When %r/^I remove the attachment from the test case "([^"]*)"$/ do |test_case|
  step "I click the element \"#delete_attachment\" for the test case \"#{test_case}\""
  step "I submit the comment for the test case \"#{test_case}\""
end

When %r/^(?:|I )attach the report "([^"]*)"$/ do |file|
  step "attach the file \"#{Dir.getwd}/features/resources/#{file}\" to \"meego_test_session[result_files_attributes][][file]\""
end

Given %r/^I select target "([^"]*)", test set "([^"]*)" and product "([^"]*)"(?: with date "([^\"]*)")?/ do |target, test_set, product, date|
  step %{I fill in "report_test_execution_date" with "#{date}"} if date
  step %{I choose "#{target}"}
  step %{I select test set "#{test_set}" and product "#{product}"}
end

Given %r/^I select test set "([^"]*)" and product "([^"]*)"(?: with date "([^\"]*)")?$/ do |test_set, product, date|
  step %{I fill in "report_test_execution_date" with "#{date}"} if date
  step %{I fill in "meego_test_session[testset]" with "#{test_set}"}
  step %{I fill in "meego_test_session[product]" with "#{product}"}
end

Given %r/^I select build id "([^"]*)"$/ do |build_id|
  step %{I fill in "meego_test_session[build_id]" with "#{build_id}"}
end

Then %r/^I should see the header$/ do
  step "I should see \"QA Reports\" within \"#header\""
end

Then %r/^I should not see the header$/ do
  step "I should not see \"#header\""
end

When %r/^I click to confirm the delete$/ do
  find('.dialog-delete').click
end

Then %r/^(?:|I )should not be able to view the report "([^"]*)"$/ do |report_string|
  version, target, test_set, product = report_string.downcase.split('/')
  report = MeegoTestSession.first(:conditions =>
   {"releases.name" => version, "profiles.name" => target, :product => product, :testset => test_set}, :include => [:release, :profile],
   :order => "tested_at DESC, created_at DESC")
  report.should == nil
end

Then %r/^(?:|I )should see feature "([^"]*)" graded as ([^"]*)$/ do |feature_name, grading_color|
  find_feature_row(feature_name).find(:xpath, "descendant::span")['class'].should =~ /#{grading_color}/ # Check that the color matches the status
end

When %r/^(?:|I )fill in comment "([^"]*)" for feature "([^"]*)"$/ do |comment, feature_name|
  find_feature_row(feature_name).find(".feature_record_notes").click()
  fill_in("feature[comments]", :with => comment)
end

When %r/^I (save|cancel) the comment of feature "([^"]*)"$/ do |action, feature_name|
  find_feature_row(feature_name).click_link_or_button(action.capitalize)
end

When %r/^I change comment of feature "([^"]*)" to "([^"]*)"$/ do |feature_name, comment|
  step %{I fill in comment "#{comment}" for feature "#{feature_name}"}
  step %{I save the comment of feature "#{feature_name}"}
end

When %r/^I change grading of feature "([^"]*)" to ([^"]*)$/ do |feature_name, grading_color|
  grading_area = find_feature_row(feature_name).find(".feature_record_grading")
  grading_area.click

  grading_area.find("option", :text => grading_color.capitalize).select_option
end

Then %r/^I should find data for the other report from the database$/ do
  MeegoTestSession.count(:conditions => {:profile_id => Profile.find_by_name('Handset').id, :testset => "NFT"}).should == 3

  # Three reports left, each with one testcase containing a serial measurement
  # and two test cases with two meego measurements each.
  SerialMeasurement.count.should == 3
  SerialMeasurementGroup.count.should == 3
  MeegoMeasurement.count.should  == 3 * 2 * 2

  # Three reports left but the first one has two attachments
  FileAttachment.count.should == 5

end

# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'check_boxes input' do
  
  include FormtasticSpecHelper
  
  describe 'for a has_many association' do
    before do
      @output_buffer = ''
      mock_everything
      
      semantic_form_for(@fred) do |builder|
        concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true))
      end
    end
    
    it_should_have_input_wrapper_with_class("check_boxes")
    it_should_have_input_wrapper_with_id("author_posts_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:check_boxes)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:check_boxes)
    it_should_use_the_collection_when_provided(:check_boxes, 'input[@type="checkbox"]')
    
    it 'should generate a legend containing a label with text for the input' do
      output_buffer.should have_tag('form li fieldset legend.label label')
      output_buffer.should have_tag('form li fieldset legend.label label', /Posts/)
    end
    
    it 'should not link the label within the legend to any input' do
      output_buffer.should_not have_tag('form li fieldset legend label[@for^="author_post_ids_"]')
    end
    

    it 'should generate an ordered list with a list item for each choice' do
      output_buffer.should have_tag('form li fieldset ol')
      output_buffer.should have_tag('form li fieldset ol li', :count => ::Post.find(:all).size)
    end

    it 'should have one option with a "checked" attribute' do
      output_buffer.should have_tag('form li input[@checked]', :count => 1)
    end

    it 'should generate hidden inputs with default value blank' do
      output_buffer.should have_tag("form li fieldset ol li label input[@type='hidden'][@value='']", :count => ::Post.find(:all).size)
    end

    describe "each choice" do

      it 'should contain a label for the radio input with a nested input and label text' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag('form li fieldset ol li label', /#{post.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='author_post_ids_#{post.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li.post_#{post.id} label")
        end
      end

      it 'should have a checkbox input for each post' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => 2)
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        ::Post.find(:all).include?(@fred.posts.first).should be_true
        output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
      end
    end

    describe 'and no object is given' do
      before(:each) do
        output_buffer.replace ''
        semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => ::Author.find(:all)))
        end
      end

      it 'should generate a fieldset with legend' do
        output_buffer.should have_tag('form li fieldset legend', /Author/)
      end

      it 'shold generate an li tag for each item in the collection' do
        output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.find(:all).size)
      end

      it 'should generate labels for each item' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should generate inputs for each item' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='checkbox']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='project[author_id][]']")
        end
      end
    end

    describe ':default option' do
    
      describe "when the object is not new and has a single value" do
        it "should select the object value (ignoring :default)" do
          output_buffer.replace ''
          @new_post.stub!(:author_ids => [@bob.id], :authors => [@bob], :new_record? => false)
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :default => [@fred.id]))
          end
          output_buffer.should have_tag("form li input[@checked]", :count => 1)
          output_buffer.should have_tag("form li input[@value='#{@bob.id}'][@checked]", :count => 1)
        end
      end
      
      describe "when the object is new and has multiple values" do
        it "should select the object values (ignoring :default)" do
          output_buffer.replace ''
          @new_post.stub!(:author_ids => [@bob.id, @fred.id], :new_record? => false)
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :default => [@fred.id]))
          end
          output_buffer.should have_tag("form li input[@checked]", :count => 2)
          output_buffer.should have_tag("form li input[@value='#{@bob.id}'][@checked]", :count => 1)
          output_buffer.should have_tag("form li input[@value='#{@bob.id}'][@checked]", :count => 1)
        end
      end
      
      describe 'when the object has no value' do
        before do
          @new_post.stub!(:author_ids => [], :authors => [])
        end
      
        it "should not select an option if the :default is nil" do
          output_buffer.replace ''
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :default => nil))
          end
          output_buffer.should_not have_tag("form li ol li input[@checked]")
        end

        it "should select a single :default if provided" do
          output_buffer.replace ''
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :default => [@fred.id]))
          end
          output_buffer.should have_tag("form li input[@checked]", :count => 1)
          output_buffer.should have_tag("form li input[@value='#{@fred.id}'][@checked]", :count => 1)
        end
        
        it "should select a multiple :default values if provided" do
          output_buffer.replace ''
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :default => [@fred.id, @bob.id]))
          end
          output_buffer.should have_tag("form li input[@checked]", :count => 2)
          output_buffer.should have_tag("form li input[@value='#{@fred.id}'][@checked]", :count => 1)
        end
      
      end
    
    end
    
    it 'should warn about :selected deprecation' do
      with_deprecation_silenced do
        ::ActiveSupport::Deprecation.should_receive(:warn)
        semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :selected => "whatever"))
        end
      end
    end
    
    it 'should warn about :selected deprecation' do
      with_deprecation_silenced do
        ::ActiveSupport::Deprecation.should_receive(:warn)
        semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :checked => "whatever"))
        end
      end
    end
    
  end

end


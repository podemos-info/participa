# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161103145826) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_posts", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_posts", ["category_id"], name: "index_categories_posts_on_category_id"
  add_index "categories_posts", ["post_id"], name: "index_categories_posts_on_post_id"

  create_table "collaborations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "amount"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_type"
    t.integer  "ccc_entity"
    t.integer  "ccc_office"
    t.integer  "ccc_dc"
    t.integer  "ccc_account"
    t.string   "iban_account"
    t.string   "iban_bic"
    t.datetime "deleted_at"
    t.integer  "status",                  default: 0
    t.string   "redsys_identifier"
    t.datetime "redsys_expiration"
    t.string   "non_user_document_vatid"
    t.string   "non_user_email"
    t.text     "non_user_data"
    t.boolean  "for_autonomy_cc"
    t.boolean  "for_town_cc"
    t.boolean  "for_island_cc"
  end

  add_index "collaborations", ["deleted_at"], name: "index_collaborations_on_deleted_at"
  add_index "collaborations", ["non_user_document_vatid"], name: "index_collaborations_on_non_user_document_vatid"
  add_index "collaborations", ["non_user_email"], name: "index_collaborations_on_non_user_email"

  create_table "election_location_questions", force: :cascade do |t|
    t.integer "election_location_id"
    t.text    "title"
    t.text    "description"
    t.string  "voting_system"
    t.string  "layout"
    t.integer "winners"
    t.integer "minimum"
    t.integer "maximum"
    t.boolean "random_order"
    t.string  "totals"
    t.string  "options_headers"
    t.text    "options"
  end

  create_table "election_locations", force: :cascade do |t|
    t.integer  "election_id"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agora_version"
    t.string   "override"
    t.text     "title"
    t.string   "layout"
    t.text     "description"
    t.string   "share_text"
    t.string   "theme"
    t.integer  "new_agora_version"
  end

  create_table "elections", force: :cascade do |t|
    t.string   "title"
    t.integer  "agora_election_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "close_message"
    t.integer  "scope"
    t.string   "info_url"
    t.string   "server"
    t.datetime "user_created_at_max"
    t.integer  "priority"
    t.string   "info_text"
    t.integer  "flags"
    t.string   "meta_description"
    t.string   "meta_image"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "impulsa_edition_categories", force: :cascade do |t|
    t.integer  "impulsa_edition_id"
    t.string   "name"
    t.integer  "category_type"
    t.integer  "winners"
    t.integer  "prize"
    t.string   "territories"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "only_authors"
    t.string   "coofficial_language"
    t.string   "schedule_model_override_file_name"
    t.string   "schedule_model_override_content_type"
    t.integer  "schedule_model_override_file_size"
    t.datetime "schedule_model_override_updated_at"
    t.string   "activities_resources_model_override_file_name"
    t.string   "activities_resources_model_override_content_type"
    t.integer  "activities_resources_model_override_file_size"
    t.datetime "activities_resources_model_override_updated_at"
    t.string   "requested_budget_model_override_file_name"
    t.string   "requested_budget_model_override_content_type"
    t.integer  "requested_budget_model_override_file_size"
    t.datetime "requested_budget_model_override_updated_at"
    t.string   "monitoring_evaluation_model_override_file_name"
    t.string   "monitoring_evaluation_model_override_content_type"
    t.integer  "monitoring_evaluation_model_override_file_size"
    t.datetime "monitoring_evaluation_model_override_updated_at"
    t.text     "wizard"
    t.text     "evaluation"
  end

  add_index "impulsa_edition_categories", ["impulsa_edition_id"], name: "index_impulsa_edition_categories_on_impulsa_edition_id"

  create_table "impulsa_edition_topics", force: :cascade do |t|
    t.integer  "impulsa_edition_id"
    t.string   "name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "impulsa_edition_topics", ["impulsa_edition_id"], name: "index_impulsa_edition_topics_on_impulsa_edition_id"

  create_table "impulsa_editions", force: :cascade do |t|
    t.string   "name",                                     null: false
    t.datetime "start_at"
    t.datetime "new_projects_until"
    t.datetime "review_projects_until"
    t.datetime "validation_projects_until"
    t.datetime "ends_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "schedule_model_file_name"
    t.string   "schedule_model_content_type"
    t.integer  "schedule_model_file_size"
    t.datetime "schedule_model_updated_at"
    t.string   "activities_resources_model_file_name"
    t.string   "activities_resources_model_content_type"
    t.integer  "activities_resources_model_file_size"
    t.datetime "activities_resources_model_updated_at"
    t.string   "requested_budget_model_file_name"
    t.string   "requested_budget_model_content_type"
    t.integer  "requested_budget_model_file_size"
    t.datetime "requested_budget_model_updated_at"
    t.string   "monitoring_evaluation_model_file_name"
    t.string   "monitoring_evaluation_model_content_type"
    t.integer  "monitoring_evaluation_model_file_size"
    t.datetime "monitoring_evaluation_model_updated_at"
    t.text     "legal"
    t.datetime "votings_start_at"
    t.datetime "publish_results_at"
    t.text     "description"
  end

  create_table "impulsa_project_state_transitions", force: :cascade do |t|
    t.integer  "impulsa_project_id"
    t.string   "namespace"
    t.string   "event"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
  end

  add_index "impulsa_project_state_transitions", ["impulsa_project_id"], name: "index_impulsa_project_state_transitions_on_impulsa_project_id"

  create_table "impulsa_project_topics", force: :cascade do |t|
    t.integer  "impulsa_project_id"
    t.integer  "impulsa_edition_topic_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "impulsa_project_topics", ["impulsa_edition_topic_id"], name: "index_impulsa_project_topics_on_impulsa_edition_topic_id"
  add_index "impulsa_project_topics", ["impulsa_project_id"], name: "index_impulsa_project_topics_on_impulsa_project_id"

  create_table "impulsa_projects", force: :cascade do |t|
    t.integer  "impulsa_edition_category_id"
    t.integer  "user_id"
    t.integer  "status",                                             default: 0, null: false
    t.string   "review_fields"
    t.text     "additional_contact"
    t.text     "counterpart_information"
    t.string   "name",                                                           null: false
    t.string   "authority"
    t.string   "authority_name"
    t.string   "authority_phone"
    t.string   "authority_email"
    t.string   "organization_name"
    t.text     "organization_address"
    t.string   "organization_web"
    t.string   "organization_nif"
    t.integer  "organization_year"
    t.string   "organization_legal_name"
    t.string   "organization_legal_nif"
    t.text     "organization_mission"
    t.text     "career"
    t.string   "counterpart"
    t.text     "territorial_context"
    t.text     "short_description"
    t.text     "long_description"
    t.text     "aim"
    t.text     "metodology"
    t.text     "population_segment"
    t.string   "video_link"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "endorsement_file_name"
    t.string   "endorsement_content_type"
    t.integer  "endorsement_file_size"
    t.datetime "endorsement_updated_at"
    t.string   "register_entry_file_name"
    t.string   "register_entry_content_type"
    t.integer  "register_entry_file_size"
    t.datetime "register_entry_updated_at"
    t.string   "statutes_file_name"
    t.string   "statutes_content_type"
    t.integer  "statutes_file_size"
    t.datetime "statutes_updated_at"
    t.string   "responsible_nif_file_name"
    t.string   "responsible_nif_content_type"
    t.integer  "responsible_nif_file_size"
    t.datetime "responsible_nif_updated_at"
    t.string   "fiscal_obligations_certificate_file_name"
    t.string   "fiscal_obligations_certificate_content_type"
    t.integer  "fiscal_obligations_certificate_file_size"
    t.datetime "fiscal_obligations_certificate_updated_at"
    t.string   "labor_obligations_certificate_file_name"
    t.string   "labor_obligations_certificate_content_type"
    t.integer  "labor_obligations_certificate_file_size"
    t.datetime "labor_obligations_certificate_updated_at"
    t.string   "last_fiscal_year_report_of_activities_file_name"
    t.string   "last_fiscal_year_report_of_activities_content_type"
    t.integer  "last_fiscal_year_report_of_activities_file_size"
    t.datetime "last_fiscal_year_report_of_activities_updated_at"
    t.string   "last_fiscal_year_annual_accounts_file_name"
    t.string   "last_fiscal_year_annual_accounts_content_type"
    t.integer  "last_fiscal_year_annual_accounts_file_size"
    t.datetime "last_fiscal_year_annual_accounts_updated_at"
    t.string   "schedule_file_name"
    t.string   "schedule_content_type"
    t.integer  "schedule_file_size"
    t.datetime "schedule_updated_at"
    t.string   "activities_resources_file_name"
    t.string   "activities_resources_content_type"
    t.integer  "activities_resources_file_size"
    t.datetime "activities_resources_updated_at"
    t.string   "requested_budget_file_name"
    t.string   "requested_budget_content_type"
    t.integer  "requested_budget_file_size"
    t.datetime "requested_budget_updated_at"
    t.string   "monitoring_evaluation_file_name"
    t.string   "monitoring_evaluation_content_type"
    t.integer  "monitoring_evaluation_file_size"
    t.datetime "monitoring_evaluation_updated_at"
    t.integer  "organization_type"
    t.string   "scanned_nif_file_name"
    t.string   "scanned_nif_content_type"
    t.integer  "scanned_nif_file_size"
    t.datetime "scanned_nif_updated_at"
    t.string   "home_certificate_file_name"
    t.string   "home_certificate_content_type"
    t.integer  "home_certificate_file_size"
    t.datetime "home_certificate_updated_at"
    t.string   "bank_certificate_file_name"
    t.string   "bank_certificate_content_type"
    t.integer  "bank_certificate_file_size"
    t.datetime "bank_certificate_updated_at"
    t.boolean  "coofficial_translation"
    t.string   "coofficial_name"
    t.text     "coofficial_short_description"
    t.string   "coofficial_video_link"
    t.integer  "total_budget"
    t.text     "coofficial_territorial_context"
    t.text     "coofficial_long_description"
    t.text     "coofficial_aim"
    t.text     "coofficial_metodology"
    t.text     "coofficial_population_segment"
    t.text     "coofficial_organization_mission"
    t.text     "coofficial_career"
    t.integer  "evaluator1_id"
    t.text     "evaluator1_invalid_reasons"
    t.string   "evaluator1_analysis_file_name"
    t.string   "evaluator1_analysis_content_type"
    t.integer  "evaluator1_analysis_file_size"
    t.datetime "evaluator1_analysis_updated_at"
    t.integer  "evaluator2_id"
    t.text     "evaluator2_invalid_reasons"
    t.string   "evaluator2_analysis_file_name"
    t.string   "evaluator2_analysis_content_type"
    t.integer  "evaluator2_analysis_file_size"
    t.datetime "evaluator2_analysis_updated_at"
    t.integer  "votes",                                              default: 0
    t.text     "wizard_values"
    t.string   "state"
    t.string   "wizard_step"
    t.text     "wizard_review"
    t.text     "evaluator1_evaluation"
    t.text     "evaluator2_evaluation"
    t.string   "evaluation_result"
  end

  add_index "impulsa_projects", ["impulsa_edition_category_id"], name: "index_impulsa_projects_on_impulsa_edition_category_id"
  add_index "impulsa_projects", ["user_id"], name: "index_impulsa_projects_on_user_id"

  create_table "microcredit_loans", force: :cascade do |t|
    t.integer  "microcredit_id"
    t.integer  "amount"
    t.integer  "user_id"
    t.text     "user_data"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "counted_at"
    t.string   "ip"
    t.string   "document_vatid"
    t.datetime "discarded_at"
    t.datetime "returned_at"
    t.integer  "transferred_to_id"
  end

  add_index "microcredit_loans", ["document_vatid"], name: "index_microcredit_loans_on_document_vatid"
  add_index "microcredit_loans", ["ip"], name: "index_microcredit_loans_on_ip"
  add_index "microcredit_loans", ["microcredit_id"], name: "index_microcredit_loans_on_microcredit_id"

  create_table "microcredits", force: :cascade do |t|
    t.string   "title"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "reset_at"
    t.text     "limits"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_number"
    t.string   "agreement_link"
    t.string   "contact_phone"
    t.integer  "total_goal"
    t.string   "slug"
    t.text     "subgoals"
    t.string   "renewal_terms_file_name"
    t.string   "renewal_terms_content_type"
    t.integer  "renewal_terms_file_size"
    t.datetime "renewal_terms_updated_at"
    t.string   "budget_link"
    t.integer  "flags",                      default: 0
  end

  add_index "microcredits", ["slug"], name: "index_microcredits_on_slug", unique: true

  create_table "notice_registrars", force: :cascade do |t|
    t.string   "registration_id"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.string   "link"
    t.datetime "final_valid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_at"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "status"
    t.datetime "payable_at"
    t.datetime "payed_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.string   "reference"
    t.integer  "amount"
    t.boolean  "first"
    t.integer  "payment_type"
    t.string   "payment_identifier"
    t.text     "payment_response"
    t.string   "town_code"
    t.string   "autonomy_code"
    t.string   "island_code"
  end

  add_index "orders", ["parent_id"], name: "index_orders_on_parent_id"

  create_table "pages", force: :cascade do |t|
    t.string   "title"
    t.integer  "id_form"
    t.string   "slug"
    t.boolean  "require_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "link"
    t.string   "meta_description"
    t.string   "meta_image"
  end

  add_index "pages", ["deleted_at"], name: "index_pages_on_deleted_at"

  create_table "participation_teams", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participation_teams_users", id: false, force: :cascade do |t|
    t.integer "participation_team_id"
    t.integer "user_id"
  end

  add_index "participation_teams_users", ["participation_team_id"], name: "index_participation_teams_users_on_participation_team_id"
  add_index "participation_teams_users", ["user_id"], name: "index_participation_teams_users_on_user_id"

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.string   "slug"
    t.integer  "status"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "media_url"
  end

  create_table "proposals", force: :cascade do |t|
    t.text     "title"
    t.text     "description"
    t.integer  "votes",            default: 0
    t.string   "reddit_url"
    t.string   "reddit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reddit_threshold", default: false
    t.string   "image_url"
    t.integer  "supports_count",   default: 0
    t.integer  "hotness",          default: 0
    t.string   "author"
  end

  create_table "report_groups", force: :cascade do |t|
    t.string   "title"
    t.text     "proc"
    t.integer  "width"
    t.string   "label"
    t.string   "data_label"
    t.text     "whitelist"
    t.text     "blacklist"
    t.integer  "minimum"
    t.string   "minimum_label"
    t.string   "visualization"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: :cascade do |t|
    t.string   "title"
    t.text     "query",      limit: 255
    t.text     "main_group"
    t.text     "groups"
    t.text     "results"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "version_at"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key"

  create_table "spam_filters", force: :cascade do |t|
    t.string   "name"
    t.text     "code"
    t.text     "data"
    t.string   "query"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "proposal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                    default: "", null: false
    t.string   "encrypted_password",       default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "born_at"
    t.boolean  "wants_newsletter"
    t.integer  "document_type"
    t.string   "document_vatid"
    t.boolean  "admin"
    t.string   "address"
    t.string   "town"
    t.string   "province"
    t.string   "postal_code"
    t.string   "country"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "phone"
    t.string   "sms_confirmation_token"
    t.datetime "confirmation_sms_sent_at"
    t.datetime "sms_confirmed_at"
    t.boolean  "has_legacy_password"
    t.integer  "failed_attempts",          default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "circle"
    t.datetime "deleted_at"
    t.string   "unconfirmed_phone"
    t.boolean  "wants_participation"
    t.string   "vote_town"
    t.integer  "flags",                    default: 0,  null: false
    t.datetime "participation_team_at"
    t.datetime "sms_check_at"
    t.string   "vote_district"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["deleted_at", "document_vatid"], name: "index_users_on_deleted_at_and_document_vatid", unique: true
  add_index "users", ["deleted_at", "email"], name: "index_users_on_deleted_at_and_email", unique: true
  add_index "users", ["deleted_at", "phone"], name: "index_users_on_deleted_at_and_phone", unique: true
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at"
  add_index "users", ["document_vatid"], name: "index_users_on_document_vatid"
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["flags"], name: "index_users_on_flags"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["sms_confirmation_token"], name: "index_users_on_sms_confirmation_token", unique: true
  add_index "users", ["vote_town"], name: "index_users_on_vote_town"

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "election_id"
    t.string   "voter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "votes", ["deleted_at"], name: "index_votes_on_deleted_at"

end

require "spec_helper"

describe "Explore meetings", type: :feature do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:current_feature) { create :feature, participatory_process: participatory_process, manifest_name: "meetings" }
  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(
      :meeting,
      meetings_count,
      feature: current_feature,
      start_time: DateTime.new(2016, 12, 13, 14, 15),
      end_time: DateTime.new(2016, 12, 13, 16, 17)
    )
  end

  before do
    switch_to_host(organization.host)
    visit path
  end

  context "index" do
    let(:path) { decidim_meetings.meetings_path(participatory_process_id: participatory_process.id, feature_id: current_feature.id) }

    it "shows all meetings for the given process" do
      expect(page).to have_selector("article.card", count: meetings_count)

      meetings.each do |meeting|
        expect(page).to have_content(translated meeting.title)
      end
    end
  end

  context "show" do
    let(:path) { decidim_meetings.meeting_path(id: meeting.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id) }
    let(:meetings_count) { 1 }
    let(:meeting) { meetings.first }

    it "shows all meeting info" do
      expect(page).to have_i18n_content(meeting.title)
      expect(page).to have_i18n_content(meeting.description)
      expect(page).to have_i18n_content(meeting.short_description)
      expect(page).to have_i18n_content(meeting.location)
      expect(page).to have_i18n_content(meeting.location_hints)
      expect(page).to have_content(meeting.address)

      within ".section.view-side" do
        expect(page).to have_content(13)
        expect(page).to have_content(/December/i)
        expect(page).to have_content("14:15 - 16:17")
      end
    end

    context "without category or scope" do
      it "does not show any tag" do
        expect(page).not_to have_selector("ul.tags.tags--meeting")
      end
    end

    context "with a category" do
      let(:meeting) do
        meeting = meetings.first
        meeting.category = create :category, participatory_process: participatory_process
        meeting.save
        meeting
      end

      it "shows tags for category" do
        expect(page).to have_selector("ul.tags.tags--meeting")
        within "ul.tags.tags--meeting" do
          expect(page).to have_content(translated(meeting.category.name))
        end
      end

      it "links to the filter for this category" do
        within "ul.tags.tags--meeting" do
          click_link translated(meeting.category.name)
        end
        expect(page).to have_select("filter_category_id", selected: translated(meeting.category.name))
      end
    end

    context "with a scope" do
      let(:meeting) do
        meeting = meetings.first
        meeting.scope = create :scope, organization: organization
        meeting.save
        meeting
      end

      it "shows tags for scope" do
        expect(page).to have_selector("ul.tags.tags--meeting")
        within "ul.tags.tags--meeting" do
          expect(page).to have_content(meeting.scope.name)
        end
      end

      it "links to the filter for this scope" do
        within "ul.tags.tags--meeting" do
          click_link meeting.scope.name
        end
        expect(page).to have_checked_field(meeting.scope.name)
      end
    end
  end
end
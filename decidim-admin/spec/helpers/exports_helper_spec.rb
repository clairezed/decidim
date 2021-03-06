# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExportsHelper do
      subject do
        Nokogiri::HTML(helper.export_dropdown(feature))
      end

      let!(:feature) { create(:feature, manifest_name: "dummy") }

      it "creates a dropdown an export for each format and artifact" do
        expect(subject.css("li.exports--dummies").length).to eq(2)
        expect(subject.css("li.exports--format--csv").length).to eq(1)
        expect(subject.css("li.exports--format--json").length).to eq(1)
      end

      it "creates links for each format" do
        link = subject.css("li.exports--format--csv.exports--dummies a")[0]
        expect(link["href"]).to eq("/admin/participatory_processes/#{feature.participatory_space.id}/features/#{feature.id}/exports.csv?id=dummies")
        expect(link["data-method"]).to eq("post")
      end
    end
  end
end

#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA
#

class ApplicationController < ActionController::Base
  helper_method :release, :profile, :testset, :product
  before_filter :find_releases
  before_filter :find_selected_release

  #protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
  end

  def find_releases
    @meego_releases = Release.release_versions
  end

  def find_selected_release
    @selected_release_version = session[:release_version] =
      valid_release(params[:release_version]) || session[:release_version] || Release.latest.label
  end

  def release
    @release ||= session[:release] = Release.find_by_label(params[:release_version]) || session[:release] || Release.latest
  end

  def profile
    @profile ||= params[:target]
  end

  def testset
    @testset ||= params[:testset]
  end

  def product
    @product ||= params[:product]
  end

  private

  def valid_release release_version
    return unless release_version.present?

    if Release.all.map(&:normalized).include? release_version.downcase
      release_version
    else
      Rails.logger.info ["Info:  Invalid release version: ", release_version]
      return nil
    end
  end

end

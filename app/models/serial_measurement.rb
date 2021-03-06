
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

require "nft"

class SerialMeasurement < ActiveRecord::Base
  belongs_to :serial_measurement_group

  include MeasurementUtils

  DELETE_BY_REPORT_ID = <<-END
    DELETE  serial_measurements
    FROM    serial_measurements

    INNER JOIN serial_measurement_groups ON
      serial_measurement_groups.id = serial_measurements.serial_measurement_group_id

    INNER JOIN meego_test_cases ON
      meego_test_cases.id = serial_measurement_groups.meego_test_case_id

    WHERE meego_test_cases.meego_test_session_id = ?;
  END

  FORMAT = "%.2f"

  def is_serial?
    true
  end

  def min_html
    #sprintf(FORMAT, min_value)
    format_value(min_value, 3)
  end

  def max_html
    #sprintf(FORMAT, max_value)
    format_value(max_value, 3)
  end

  def avg_html
    #sprintf(FORMAT, avg_value)
    format_value(avg_value, 3)
  end

  def med_html
    #sprintf(FORMAT, median_value)
    format_value(median_value, 3)
  end

  def small_chart_series
    {name: name, unit: unit, data: JSON.parse(short_json)}.to_json
  end

  def self.delete_by_report_id(id)
    ActiveRecord::Base.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, [DELETE_BY_REPORT_ID, id]))
  end

end

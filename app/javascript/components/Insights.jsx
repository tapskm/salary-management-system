import React, { useState, useEffect } from "react";

export default function Insights() {
  const [countryStats, setCountryStats] = useState([]);
  const [jobTitleStats, setJobTitleStats] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchInsights();
  }, []);

  const fetchInsights = async () => {
    try {
      setLoading(true);
      const response = await fetch('/employees/insights', {
        headers: { "Accept": "application/json" }
      });
      const data = await response.json();
      setCountryStats(data.country_stats || []);
      setJobTitleStats(data.job_title_stats || []);
    } catch (error) {
      console.error('Error fetching insights:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="flex justify-center items-center h-64">
          <div className="text-xl text-gray-600">Loading insights...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800 border-b pb-4">
          HR Salary Insights
        </h1>
      </div>

      {/* Country Statistics */}
      <div className="mb-12">
        <h2 className="text-xl font-semibold mb-6 text-blue-700">
          Salary Metrics by Country
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {countryStats.map((stat, index) => (
            <div 
              key={index}
              className="bg-white p-6 rounded-lg shadow-lg border-l-4 border-blue-500 hover:shadow-xl transition-shadow"
            >
              <h3 className="text-lg font-bold text-gray-700 uppercase mb-2">
                {stat.country}
              </h3>
              <p className="text-sm text-gray-500 mb-4">
                {stat.total_count} Total Employees
              </p>
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-gray-600">Average:</span>
                  <span className="font-bold text-green-600">
                    ${Number(stat.avg_salary).toLocaleString()}
                  </span>
                </div>
                <div className="flex justify-between items-center text-sm text-gray-500">
                  <span>Range:</span>
                  <span>
                    ${Number(stat.min_salary).toLocaleString()} - ${Number(stat.max_salary).toLocaleString()}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Job Title Statistics */}
      <div className="mb-8">
        <h2 className="text-xl font-semibold mb-6 text-purple-700">
          Average Salary by Role & Country
        </h2>
        <div className="bg-white shadow-lg rounded-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="bg-purple-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-purple-700 uppercase tracking-wider">
                    Country
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-purple-700 uppercase tracking-wider">
                    Job Title
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-purple-700 uppercase tracking-wider">
                    Average Salary
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {jobTitleStats.map((stat, index) => (
                  <tr 
                    key={index}
                    className={index % 2 === 0 ? "bg-white" : "bg-gray-50"}
                  >
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {stat.country}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                      {stat.job_title}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-right font-semibold text-gray-800">
                      ${Number(stat.avg_salary).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Back to Employees Link */}
      <div className="text-center">
        <a
          href="/"
          className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
        >
          ← Back to Employee List
        </a>
      </div>
    </div>
  );
}

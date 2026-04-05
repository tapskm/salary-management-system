import React, { useState, useEffect } from "react";

export default function Insights() {
  const [insightsData, setInsightsData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    fetchInsights(currentPage);
  }, [currentPage]);

  const fetchInsights = async (page = 1) => {
    try {
      setLoading(true);
      const response = await fetch(`/employees/insights?page=${page}&per_page=20`, {
        headers: { "Accept": "application/json" }
      });
      const data = await response.json();
      setInsightsData(data);
    } catch (error) {
      console.error('Error fetching insights:', error);
    } finally {
      setLoading(false);
    }
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          <div className="ml-4 text-xl text-gray-600">Loading insights...</div>
        </div>
      </div>
    );
  }

  if (!insightsData) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center text-red-600">Failed to load insights data.</div>
      </div>
    );
  }

  // Safely destructure the data with fallbacks
  const company_stats = insightsData.company_stats || {};
  const country_stats = insightsData.country_stats || [];
  const job_title_stats = insightsData.job_title_stats || { data: [], pagination: { current_page: 1, total_pages: 1, total_count: 0, per_page: 20 } };
  const department_stats = insightsData.department_stats || [];
  const salary_distribution = insightsData.salary_distribution || {};
  const top_paying_jobs = insightsData.top_paying_jobs || [];

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-gray-800 border-b pb-4">
          <i className="fas fa-chart-bar mr-3"></i>HR Analytics Dashboard
        </h1>
        <p className="text-gray-600 mt-2">Comprehensive salary and workforce insights</p>
      </div>

      {/* Tab Navigation */}
      <div className="mb-8">
        <nav className="flex space-x-8">
          {[
            { key: 'overview', label: 'Overview', icon: 'fas fa-chart-line' },
            { key: 'countries', label: 'Countries', icon: 'fas fa-globe' },
            { key: 'roles', label: 'Roles & Salaries', icon: 'fas fa-briefcase' },
            { key: 'departments', label: 'Departments', icon: 'fas fa-building' },
            { key: 'distribution', label: 'Salary Range', icon: 'fas fa-chart-pie' }
          ].map(tab => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`px-4 py-2 rounded-lg font-medium transition-all flex items-center space-x-2 ${
                activeTab === tab.key
                  ? 'bg-blue-600 text-white shadow-lg'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <i className={tab.icon}></i>
              <span>{tab.label}</span>
            </button>
          ))}
        </nav>
      </div>

      {/* Overview Tab */}
      {activeTab === 'overview' && (
        <div className="space-y-8">
          {/* Company Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white p-6 rounded-lg shadow-lg">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm opacity-80">Total Employees</div>
                  <div className="text-3xl font-bold">{(company_stats.total_employees || 0).toLocaleString()}</div>
                </div>
                <i className="fas fa-users text-3xl opacity-60"></i>
              </div>
            </div>
            <div className="bg-gradient-to-r from-green-500 to-green-600 text-white p-6 rounded-lg shadow-lg">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm opacity-80">Total Budget</div>
                  <div className="text-3xl font-bold">${(company_stats.total_budget || 0).toLocaleString()}</div>
                </div>
                <i className="fas fa-dollar-sign text-3xl opacity-60"></i>
              </div>
            </div>
            <div className="bg-gradient-to-r from-purple-500 to-purple-600 text-white p-6 rounded-lg shadow-lg">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm opacity-80">Average Salary</div>
                  <div className="text-3xl font-bold">${Math.round(company_stats.average_salary || 0).toLocaleString()}</div>
                </div>
                <i className="fas fa-chart-line text-3xl opacity-60"></i>
              </div>
            </div>
            <div className="bg-gradient-to-r from-orange-500 to-orange-600 text-white p-6 rounded-lg shadow-lg">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm opacity-80">Recent Hires (30d)</div>
                  <div className="text-2xl font-bold flex items-center">
                    {company_stats.recent_hires || 0}
                    {(company_stats.hiring_trend || 'stable') === 'up' && <i className="fas fa-arrow-up ml-2 text-sm"></i>}
                    {(company_stats.hiring_trend || 'stable') === 'down' && <i className="fas fa-arrow-down ml-2 text-sm"></i>}
                    {(company_stats.hiring_trend || 'stable') === 'stable' && <i className="fas fa-minus ml-2 text-sm"></i>}
                  </div>
                </div>
                <i className="fas fa-user-plus text-3xl opacity-60"></i>
              </div>
            </div>
          </div>

          {/* Top Paying Jobs */}
          <div className="bg-white p-6 rounded-lg shadow-lg">
            <h3 className="text-xl font-bold text-gray-800 mb-4 flex items-center">
              <i className="fas fa-money-bill-wave mr-2 text-green-600"></i>
              Top Paying Positions
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {top_paying_jobs.slice(0, 6).map((job, index) => (
                <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                  <div>
                    <div className="font-medium text-gray-800 flex items-center">
                      <i className="fas fa-briefcase mr-2 text-blue-600"></i>
                      {job.job_title}
                    </div>
                    <div className="text-sm text-gray-500 flex items-center">
                      <i className="fas fa-user mr-1"></i>
                      {job.count} employees
                    </div>
                  </div>
                  <div className="text-lg font-bold text-green-600">
                    ${Math.round(job.avg_salary).toLocaleString()}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Countries Tab */}
      {activeTab === 'countries' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {country_stats.map((stat, index) => (
            <div key={index} className="bg-white p-6 rounded-lg shadow-lg border-l-4 border-blue-500 hover:shadow-xl transition-shadow">
              <h3 className="text-lg font-bold text-gray-700 uppercase mb-2 flex items-center">
                <i className="fas fa-globe mr-2 text-blue-600"></i>
                {stat.country}
              </h3>
              <p className="text-sm text-gray-500 mb-4 flex items-center">
                <i className="fas fa-users mr-2"></i>
                {stat.total_count} Total Employees
              </p>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-gray-600 flex items-center">
                    <i className="fas fa-dollar-sign mr-2"></i>
                    Average:
                  </span>
                  <span className="font-bold text-green-600">
                    ${Number(stat.avg_salary).toLocaleString()}
                  </span>
                </div>
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-600 flex items-center">
                    <i className="fas fa-chart-bar mr-2"></i>
                    Range:
                  </span>
                  <span className="text-gray-700">
                    ${Number(stat.min_salary).toLocaleString()} - ${Number(stat.max_salary).toLocaleString()}
                  </span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-blue-500 h-2 rounded-full" 
                    style={{width: `${country_stats.length > 0 ? (stat.total_count / Math.max(...country_stats.map(s => s.total_count))) * 100 : 0}%`}}
                  ></div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Roles Tab with Pagination */}
      {activeTab === 'roles' && (
        <div className="space-y-6">
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <div className="bg-gradient-to-r from-purple-500 to-purple-600 text-white px-6 py-4">
              <h2 className="text-xl font-semibold flex items-center">
                <i className="fas fa-briefcase mr-3"></i>
                Average Salary by Role & Country
              </h2>
              <p className="text-purple-100">Detailed breakdown of compensation by position and location</p>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead className="bg-purple-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-purple-700 uppercase tracking-wider">
                      <i className="fas fa-globe mr-2"></i>Country
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-purple-700 uppercase tracking-wider">
                      <i className="fas fa-briefcase mr-2"></i>Job Title
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-purple-700 uppercase tracking-wider">
                      <i className="fas fa-dollar-sign mr-2"></i>Average Salary
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-purple-700 uppercase tracking-wider">
                      <i className="fas fa-users mr-2"></i>Count
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {job_title_stats.data.map((stat, index) => (
                    <tr key={index} className={index % 2 === 0 ? "bg-white hover:bg-gray-50" : "bg-gray-50 hover:bg-gray-100"}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        <i className="fas fa-globe mr-2 text-blue-600"></i>
                        {stat.country}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {stat.job_title}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-right font-semibold text-green-600">
                        ${Number(stat.avg_salary).toLocaleString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-right text-gray-500">
                        {stat.employee_count}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Pagination */}
          <div className="flex justify-between items-center bg-white px-6 py-4 rounded-lg shadow">
            <div className="text-sm text-gray-600">
              Showing page {job_title_stats.pagination.current_page} of {job_title_stats.pagination.total_pages} 
              ({job_title_stats.pagination.total_count} total combinations)
            </div>
            <div className="flex space-x-2">
              <button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                className="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-blue-700 transition"
              >
                ← Previous
              </button>
              <span className="px-4 py-2 bg-gray-100 rounded">
                {currentPage} / {job_title_stats.pagination.total_pages}
              </span>
              <button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === job_title_stats.pagination.total_pages}
                className="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-blue-700 transition"
              >
                Next →
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Departments Tab */}
      {activeTab === 'departments' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {department_stats.map((dept, index) => (
            <div key={index} className="bg-white p-6 rounded-lg shadow-lg border-l-4 border-green-500">
              <h3 className="text-lg font-bold text-gray-700 mb-4 flex items-center">
                <i className="fas fa-building mr-2 text-green-600"></i>
                {dept.department}
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">${Math.round(dept.avg_salary).toLocaleString()}</div>
                  <div className="text-sm text-gray-500">Average Salary</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">{dept.staff_count}</div>
                  <div className="text-sm text-gray-500">Staff Count</div>
                </div>
                <div className="text-center">
                  <div className="text-lg font-bold text-purple-600">${dept.total_budget.toLocaleString()}</div>
                  <div className="text-sm text-gray-500">Total Budget</div>
                </div>
                <div className="text-center">
                  <div className="text-sm text-gray-600">
                    ${dept.min_salary.toLocaleString()} - ${dept.max_salary.toLocaleString()}
                  </div>
                  <div className="text-sm text-gray-500">Salary Range</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Salary Distribution Tab */}
      {activeTab === 'distribution' && (
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-xl font-bold text-gray-800 mb-6 flex items-center">
            <i className="fas fa-chart-pie mr-3 text-blue-600"></i>
            Salary Distribution
          </h3>
          <div className="space-y-4">
            {Object.entries(salary_distribution).map(([range, count]) => {
              const allValues = Object.values(salary_distribution);
              const maxCount = allValues.length > 0 ? Math.max(...allValues) : 1;
              const percentage = maxCount > 0 ? (count / maxCount) * 100 : 0;
              const totalEmployees = company_stats.total_employees || 1;
              return (
                <div key={range} className="flex items-center space-x-4">
                  <div className="w-20 text-sm font-medium text-gray-600">{range}</div>
                  <div className="flex-1 bg-gray-200 rounded-full h-6 relative">
                    <div 
                      className="bg-gradient-to-r from-blue-500 to-purple-600 h-6 rounded-full flex items-center justify-end pr-2"
                      style={{width: `${percentage}%`}}
                    >
                      {count > 0 && (
                        <span className="text-white text-sm font-medium">{count}</span>
                      )}
                    </div>
                  </div>
                  <div className="w-16 text-sm text-gray-500 text-right">
                    {((count / totalEmployees) * 100).toFixed(1)}%
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Back to Employees Link */}
      <div className="text-center mt-12">
        <a
          href="/"
          className="inline-flex items-center px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all shadow-lg hover:shadow-xl"
        >
          <i className="fas fa-arrow-left mr-2"></i>
          Back to Employee List
        </a>
      </div>
    </div>
  );
}

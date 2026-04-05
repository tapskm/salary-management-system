import React, { useState, useEffect } from "react";

export default function EmployeeForm({ employee = null, onSave, onCancel }) {
  const [formData, setFormData] = useState({
    full_name: "",
    job_title: "",
    country: "",
    salary: "",
    department: ""
  });
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (employee) {
      setFormData({
        full_name: employee.full_name || "",
        job_title: employee.job_title || "",
        country: employee.country || "",
        salary: employee.salary || "",
        department: employee.department || ""
      });
    }
  }, [employee]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear specific error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: null
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});
    
    const url = employee ? `/employees/${employee.id}` : '/employees';
    const method = employee ? 'PATCH' : 'POST';
    
    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({ employee: formData })
      });

      const responseData = await response.json();

      if (response.ok) {
        onSave(responseData);
      } else {
        setErrors(responseData || {});
        console.error('Validation errors:', responseData);
      }
    } catch (error) {
      console.error('Error:', error);
      setErrors({ general: 'Network error. Please try again.' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-8 rounded-lg shadow-xl max-w-lg w-full mx-4 max-h-screen overflow-y-auto">
        <h2 className="text-2xl font-bold mb-6 text-gray-800">
          {employee ? 'Edit Employee' : 'Add New Employee'}
        </h2>
        
        {errors.general && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {errors.general}
          </div>
        )}
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-gray-700 font-bold mb-2">Full Name *</label>
            <input
              type="text"
              name="full_name"
              value={formData.full_name}
              onChange={handleChange}
              required
              className={`w-full border p-3 rounded focus:outline-none focus:border-blue-500 ${
                errors.full_name ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Enter full name"
              disabled={loading}
            />
            {errors.full_name && (
              <p className="text-red-500 text-sm mt-1">{errors.full_name[0]}</p>
            )}
          </div>

          <div>
            <label className="block text-gray-700 font-bold mb-2">Job Title *</label>
            <input
              type="text"
              name="job_title"
              value={formData.job_title}
              onChange={handleChange}
              required
              className={`w-full border p-3 rounded focus:outline-none focus:border-blue-500 ${
                errors.job_title ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Enter job title"
              disabled={loading}
            />
            {errors.job_title && (
              <p className="text-red-500 text-sm mt-1">{errors.job_title[0]}</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-gray-700 font-bold mb-2">Country *</label>
              <input
                type="text"
                name="country"
                value={formData.country}
                onChange={handleChange}
                required
                className={`w-full border p-3 rounded focus:outline-none focus:border-blue-500 ${
                  errors.country ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="Enter country"
                disabled={loading}
              />
              {errors.country && (
                <p className="text-red-500 text-sm mt-1">{errors.country[0]}</p>
              )}
            </div>
            <div>
              <label className="block text-gray-700 font-bold mb-2">Salary *</label>
              <input
                type="number"
                name="salary"
                value={formData.salary}
                onChange={handleChange}
                required
                min="0"
                step="0.01"
                className={`w-full border p-3 rounded focus:outline-none focus:border-blue-500 ${
                  errors.salary ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="Enter salary"
                disabled={loading}
              />
              {errors.salary && (
                <p className="text-red-500 text-sm mt-1">{errors.salary[0]}</p>
              )}
            </div>
          </div>

          <div>
            <label className="block text-gray-700 font-bold mb-2">Department</label>
            <input
              type="text"
              name="department"
              value={formData.department}
              onChange={handleChange}
              className={`w-full border p-3 rounded focus:outline-none focus:border-blue-500 ${
                errors.department ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Enter department (optional)"
              disabled={loading}
            />
            {errors.department && (
              <p className="text-red-500 text-sm mt-1">{errors.department[0]}</p>
            )}
          </div>

          <div className="flex justify-end space-x-4 pt-6">
            <button
              type="button"
              onClick={onCancel}
              disabled={loading}
              className="px-6 py-2 border border-gray-300 text-gray-700 rounded hover:bg-gray-50 transition disabled:opacity-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition disabled:opacity-50 flex items-center space-x-2"
            >
              {loading && (
                <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              )}
              <span>{loading ? 'Saving...' : (employee ? 'Update Employee' : 'Create Employee')}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

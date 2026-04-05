import React, { useState, useEffect } from "react";
import EmployeeForm from "./components/EmployeeForm";

export default function SalaryManager() {
  const [employees, setEmployees] = useState([]);
  const [page, setPage] = useState(1);
  const [meta, setMeta] = useState({ total_pages: 1 });
  const [showForm, setShowForm] = useState(false);
  const [editingEmployee, setEditingEmployee] = useState(null);

  useEffect(() => {
    fetchEmployees();
  }, [page]);

  const fetchEmployees = () => {
    fetch(`/employees?page=${page}`, { headers: { "Accept": "application/json" } })
      .then(res => res.json())
      .then(data => {
        setEmployees(data.employees);
        setMeta(data.meta);
      })
      .catch(error => console.error('Error fetching employees:', error));
  };

  const handleAddNew = () => {
    setEditingEmployee(null);
    setShowForm(true);
  };

  const handleEdit = (employee) => {
    setEditingEmployee(employee);
    setShowForm(true);
  };

  const handleDelete = async (employeeId) => {
    if (confirm('Are you sure you want to delete this employee?')) {
      try {
        const response = await fetch(`/employees/${employeeId}`, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').getAttribute('content')
          }
        });

        if (response.ok) {
          fetchEmployees(); // Refresh the list
        } else {
          alert('Error deleting employee. Please try again.');
        }
      } catch (error) {
        console.error('Error deleting employee:', error);
        alert('Error deleting employee. Please try again.');
      }
    }
  };

  const handleFormSave = (savedEmployee) => {
    setShowForm(false);
    setEditingEmployee(null);
    fetchEmployees(); // Refresh the list
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setEditingEmployee(null);
  };

  return (
    <div className="p-8 max-w-7xl mx-auto">
      {/* Header with Add New Button */}
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-blue-600">HR Salary Manager</h1>
        <button
          onClick={handleAddNew}
          className="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700 transition flex items-center space-x-2"
        >
          <span>+</span>
          <span>Add New Employee</span>
        </button>
      </div>

      {/* Employee Table */}
      <div className="bg-white shadow rounded-lg overflow-hidden border border-gray-200">
        <table className="w-full text-left">
          <thead className="bg-gray-50 border-b text-xs uppercase text-gray-500">
            <tr>
              <th className="p-4">Full Name</th>
              <th className="p-4">Job Title</th>
              <th className="p-4">Country</th>
              <th className="p-4">Department</th>
              <th className="p-4 text-right">Salary</th>
              <th className="p-4 text-center">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {employees.map(emp => (
              <tr key={emp.id} className="hover:bg-blue-50 transition">
                <td className="p-4 text-sm font-medium">{emp.full_name}</td>
                <td className="p-4 text-sm text-gray-600">{emp.job_title}</td>
                <td className="p-4 text-sm text-gray-600">{emp.country}</td>
                <td className="p-4 text-sm text-gray-600">{emp.department || 'N/A'}</td>
                <td className="p-4 text-sm text-right font-bold text-green-600">
                  ${Number(emp.salary).toLocaleString()}
                </td>
                <td className="p-4 text-center">
                  <div className="flex justify-center space-x-2">
                    <button
                      onClick={() => handleEdit(emp)}
                      className="bg-blue-500 text-white px-3 py-1 rounded text-xs hover:bg-blue-600 transition"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => handleDelete(emp.id)}
                      className="bg-red-500 text-white px-3 py-1 rounded text-xs hover:bg-red-600 transition"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        
        {/* Pagination */}
        <div className="p-4 bg-gray-50 flex justify-between items-center border-t">
          <button 
            disabled={page === 1} 
            onClick={() => setPage(p => p - 1)}
            className="px-4 py-2 bg-white border rounded shadow-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50 transition"
          >
            Previous
          </button>
          <span className="text-sm font-medium text-gray-600">
            Page {page} of {meta.total_pages}
          </span>
          <button 
            disabled={page === meta.total_pages} 
            onClick={() => setPage(p => p + 1)}
            className="px-4 py-2 bg-white border rounded shadow-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50 transition"
          >
            Next
          </button>
        </div>
      </div>

      {/* Employee Form Modal */}
      {showForm && (
        <EmployeeForm
          employee={editingEmployee}
          onSave={handleFormSave}
          onCancel={handleFormCancel}
        />
      )}
    </div>
  );
}
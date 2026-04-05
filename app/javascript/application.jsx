import "@hotwired/turbo-rails"
import "./controllers"
import React from "react"
import { createRoot } from "react-dom/client"
import SalaryManager from "./SalaryManager.jsx"
import Insights from "./components/Insights.jsx"

// Store roots to prevent creating multiple roots for the same container
const roots = new Map()

// Function to mount React components safely
function mountReact() {
  // Mount SalaryManager on index page
  const container = document.getElementById("root")
  if (container) {
    let root = roots.get("root")
    
    if (!root) {
      // Create new root only if it doesn't exist
      root = createRoot(container)
      roots.set("root", root)
    }
    
    root.render(<SalaryManager />)
  }

  // Mount Insights on insights page
  const insightsContainer = document.getElementById("insights-root")
  if (insightsContainer) {
    let insightsRoot = roots.get("insights-root")
    
    if (!insightsRoot) {
      // Create new root only if it doesn't exist
      insightsRoot = createRoot(insightsContainer)
      roots.set("insights-root", insightsRoot)
    }
    
    insightsRoot.render(<Insights />)
  }
}

// Function to cleanup roots when navigating away
function cleanupRoots() {
  // Only cleanup roots for containers that no longer exist
  roots.forEach((root, containerId) => {
    const container = document.getElementById(containerId)
    if (!container) {
      root.unmount()
      roots.delete(containerId)
    }
  })
}

// Mount on first load
document.addEventListener("DOMContentLoaded", mountReact)

// Mount on Turbo navigation (for SPA-like behavior)
document.addEventListener("turbo:load", () => {
  cleanupRoots()
  mountReact()
})

// Cleanup when leaving the page
document.addEventListener("turbo:before-visit", cleanupRoots)
import React, { Suspense, lazy } from 'react'
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import { SharedButton } from '@repo/ui'

// @ts-ignore
const Mfe1 = lazy(() => import('mfe1/App'))
// @ts-ignore
const Mfe2 = lazy(() => import('mfe2/App'))

export default () => (
  <BrowserRouter>
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Host Shell</h1>
      <nav style={{ display: 'flex', gap: 15, marginBottom: '30px', background: '#f4f4f4', padding: '15px', borderRadius: '8px' }}>
        <Link to="/" style={{ textDecoration: 'none' }}><SharedButton text="Home" /></Link>
        <Link to="/mfe1" style={{ textDecoration: 'none' }}><SharedButton text="MFE 1" /></Link>
        <Link to="/mfe2" style={{ textDecoration: 'none' }}><SharedButton text="MFE 2" /></Link>
      </nav>
      <div style={{ border: '2px solid #0070f3', padding: '20px', borderRadius: '10px' }}>
        <Routes>
          <Route path="/" element={<div><h2>Welcome to the Shell</h2><p>Select an MFE above to load it at runtime.</p></div>} />
          <Route path="/mfe1" element={<Suspense fallback="Loading MFE1..."><Mfe1 /></Suspense>} />
          <Route path="/mfe2" element={<Suspense fallback="Loading MFE2..."><Mfe2 /></Suspense>} />
        </Routes>
      </div>
    </div>
  </BrowserRouter>
)

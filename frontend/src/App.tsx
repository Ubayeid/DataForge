import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import { theme } from './theme';

// Components
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Pipelines from './pages/Pipelines';
import Sources from './pages/Sources';
import Monitoring from './pages/Monitoring';
import Settings from './pages/Settings';

// Styles
import { Box, Container } from '@mui/material';
import { styled } from '@mui/material/styles';

const AppContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  minHeight: '100vh',
  backgroundColor: theme.palette.background.default,
}));

const MainContent = styled(Box)(({ theme }) => ({
  flexGrow: 1,
  padding: theme.spacing(3),
  marginTop: 64, // Height of navbar
  marginLeft: 240, // Width of sidebar
}));

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <AppContainer>
          <Navbar />
          <Sidebar />
          <MainContent>
            <Container maxWidth="lg">
              <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/pipelines" element={<Pipelines />} />
                <Route path="/sources" element={<Sources />} />
                <Route path="/monitoring" element={<Monitoring />} />
                <Route path="/settings" element={<Settings />} />
              </Routes>
            </Container>
          </MainContent>
        </AppContainer>
      </Router>
    </ThemeProvider>
  );
}

export default App; 
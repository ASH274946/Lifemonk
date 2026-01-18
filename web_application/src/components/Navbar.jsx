import React, { useState, useEffect } from 'react';
import { Menu, X, Download, Sun, Moon, Monitor } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Link, useLocation } from 'react-router-dom';

const Navbar = () => {
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const location = useLocation();
    const [theme, setTheme] = useState(
        () => localStorage.getItem('theme') || 'system'
    );

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 20);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    // Theme Logic
    useEffect(() => {
        const root = window.document.documentElement;
        root.classList.remove('light', 'dark');

        if (theme === 'system') {
            const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
                ? 'dark'
                : 'light';
            root.classList.add(systemTheme);
            return;
        }

        root.classList.add(theme);
        localStorage.setItem('theme', theme);
    }, [theme]);

    useEffect(() => {
        if (theme !== 'system') return;
        const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');

        const handleChange = () => {
            const root = window.document.documentElement;
            if (theme === 'system') {
                root.classList.remove('light', 'dark');
                root.classList.add(mediaQuery.matches ? 'dark' : 'light');
            }
        };

        mediaQuery.addEventListener('change', handleChange);
        return () => mediaQuery.removeEventListener('change', handleChange);
    }, [theme]);

    const toggleTheme = () => {
        const newTheme = theme === 'light' ? 'dark' : theme === 'dark' ? 'system' : 'light';
        setTheme(newTheme);
    };

    const getThemeIcon = () => {
        switch (theme) {
            case 'light': return <Sun size={20} />;
            case 'dark': return <Moon size={20} />;
            case 'system': return <Monitor size={20} />;
            default: return <Monitor size={20} />;
        }
    };

    const navLinks = [
        { name: 'Home', href: '/' },
        { name: 'Features', href: '/#features' },
        { name: 'About', href: '/#about' },
        { name: 'Pricing', href: '/pricing' },
        { name: 'Contact', href: '/contact' },
    ];

    // Handle hash scrolling
    useEffect(() => {
        if (location.hash) {
            const elem = document.getElementById(location.hash.slice(1));
            if (elem) {
                elem.scrollIntoView({ behavior: 'smooth' });
            }
        }
    }, [location]);

    return (
        <nav
            className={`fixed z-50 left-1/2 -translate-x-1/2 transition-[top,width,max-width,background-color,border-radius,box-shadow,padding,backdrop-filter,border-color,transform] duration-[1800ms] ease-[cubic-bezier(0.4,0,0.2,1)] ${isScrolled
                ? 'top-6 w-[90%] md:max-w-4xl rounded-full bg-white/70 dark:bg-gray-900/70 backdrop-blur-2xl shadow-[0_8px_32px_rgba(0,0,0,0.12),0_4px_16px_rgba(0,0,0,0.08)] dark:shadow-[0_8px_32px_rgba(0,0,0,0.4),0_4px_16px_rgba(0,0,0,0.3)] border border-gray-100/50 dark:border-gray-800/50 py-1 scale-100'
                : 'top-0 w-full max-w-none rounded-none bg-transparent shadow-none border border-transparent py-0 scale-100'
                }`}
        >
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex justify-between items-center h-20">
                    {/* Logo */}
                    <Link to="/" className="flex-shrink-0 flex items-center gap-2 cursor-pointer" onClick={() => window.scrollTo(0, 0)}>
                        <img src="/lifemonk_logo.png" alt="Lifemonk" className="h-10 w-10 rounded-xl shadow-sm" />
                        <span className={`font-bold text-2xl tracking-tight transition-colors duration-300 ${isScrolled ? 'text-gray-900 dark:text-white' : 'text-text-primary'}`}>Lifemonk</span>
                    </Link>

                    {/* Right side - Theme, Hamburger, Get App */}
                    <div className="flex items-center gap-4">
                        {/* Theme Toggle Button */}
                        <button
                            onClick={toggleTheme}
                            className="p-2 rounded-xl text-text-secondary hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                            title={`Current theme: ${theme}`}
                        >
                            {getThemeIcon()}
                        </button>

                        {/* Hamburger Menu Container */}
                        <div className="relative">
                            {/* Hamburger Menu Button */}
                            <button
                                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                                className="p-2 rounded-xl text-text-primary hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                            >
                                {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
                            </button>

                            {/* Dropdown Menu */}
                            <AnimatePresence>
                                {isMobileMenuOpen && (
                                    <motion.div
                                        initial={{ opacity: 0, y: -10, scale: 0.95 }}
                                        animate={{ opacity: 1, y: 0, scale: 1 }}
                                        exit={{ opacity: 0, y: -10, scale: 0.95 }}
                                        transition={{ duration: 0.2 }}
                                        className="absolute right-0 top-full mt-2 w-56 bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 shadow-xl rounded-xl overflow-hidden z-50"
                                    >
                                        <div className="py-3">
                                            {navLinks.map((link) => (
                                                <Link
                                                    key={link.name}
                                                    to={link.href}
                                                    onClick={() => setIsMobileMenuOpen(false)}
                                                    className="block px-5 py-3 text-base font-medium text-text-secondary hover:text-primary-DEFAULT hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                                                >
                                                    {link.name}
                                                </Link>
                                            ))}
                                        </div>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>

                        {/* Get App Button */}
                        <a
                            href="/lifemonk.apk"
                            download="lifemonk.apk"
                            className="hidden sm:flex bg-primary-light text-white px-5 py-2.5 rounded-full font-semibold hover:bg-primary-DEFAULT transition-all duration-300 shadow-lg shadow-primary-light/30 items-center gap-2 transform hover:-translate-y-0.5"
                        >
                            <Download size={18} />
                            <span>Get App</span>
                        </a>
                    </div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;

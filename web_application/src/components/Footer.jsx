import React from 'react';
import { Facebook, Twitter, Instagram, Linkedin, Heart } from 'lucide-react';
import { Link } from 'react-router-dom';

const Footer = () => {
    return (
        <footer className="bg-background-cream dark:bg-background-cream/5 pt-20 pb-10">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
                    <div className="col-span-1 md:col-span-1">
                        <Link to="/" className="flex items-center gap-2 mb-6">
                            <img src="/lifemonk_logo.png" alt="Lifemonk" className="w-8 h-8 rounded-lg shadow-sm" />
                            <span className="font-bold text-xl text-text-primary">Lifemonk</span>
                        </Link>
                        <p className="text-text-secondary text-sm leading-relaxed mb-6">
                            Empowering children with the skills they need for a brighter, happier future.
                        </p>
                        <div className="flex space-x-4">
                            {[Facebook, Twitter, Instagram, Linkedin].map((Icon, i) => (
                                <a key={i} href="#" className="w-8 h-8 rounded-full bg-background-white dark:bg-background-white/10 flex items-center justify-center text-text-secondary hover:text-primary-DEFAULT hover:shadow-md transition-all">
                                    <Icon size={16} />
                                </a>
                            ))}
                        </div>
                    </div>

                    <div>
                        <h4 className="font-bold text-text-primary mb-6">Product</h4>
                        <ul className="space-y-3 text-sm text-text-secondary">
                            <li><Link to="/#courses" className="hover:text-primary-DEFAULT transition-colors">Courses</Link></li>
                            <li><Link to="/#features" className="hover:text-primary-DEFAULT transition-colors">Features</Link></li>
                            <li><Link to="/schools" className="hover:text-primary-DEFAULT transition-colors">For Schools</Link></li>
                            <li><Link to="/pricing" className="hover:text-primary-DEFAULT transition-colors">Pricing</Link></li>
                        </ul>
                    </div>

                    <div>
                        <h4 className="font-bold text-text-primary mb-6">Company</h4>
                        <ul className="space-y-3 text-sm text-text-secondary">
                            <li><Link to="/#about" className="hover:text-primary-DEFAULT transition-colors">About Us</Link></li>
                            <li><Link to="/contact" className="hover:text-primary-DEFAULT transition-colors">Careers</Link></li>
                            <li><Link to="/blog" className="hover:text-primary-DEFAULT transition-colors">Blog</Link></li>
                            <li><Link to="/contact" className="hover:text-primary-DEFAULT transition-colors">Contact</Link></li>
                        </ul>
                    </div>

                    <div>
                        <h4 className="font-bold text-text-primary mb-6">Legal</h4>
                        <ul className="space-y-3 text-sm text-text-secondary">
                            <li><Link to="/privacy" className="hover:text-primary-DEFAULT transition-colors">Privacy Policy</Link></li>
                            <li><Link to="/terms" className="hover:text-primary-DEFAULT transition-colors">Terms of Service</Link></li>
                            <li><Link to="/cookies" className="hover:text-primary-DEFAULT transition-colors">Cookie Policy</Link></li>
                        </ul>
                    </div>
                </div>

                <div className="border-t border-gray-200 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
                    <p className="text-sm text-text-light">
                        © {new Date().getFullYear()} Lifemonk. All rights reserved.
                    </p>
                    <p className="text-sm text-text-light flex items-center gap-1">
                        Made with <Heart size={14} className="text-red-400 fill-red-400" /> for kids everywhere.
                    </p>
                </div>
            </div>
        </footer>
    );
};

export default Footer;

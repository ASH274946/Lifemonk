import React from 'react';
import { Mail, MapPin, Phone } from 'lucide-react';

const Contact = () => {
    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-7xl mx-auto">
            <h1 className="text-4xl md:text-5xl font-bold text-text-primary text-center mb-12">Contact Us</h1>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
                {/* Contact Info */}
                <div className="space-y-8 bg-white/50 dark:bg-gray-900/50 backdrop-blur-md p-8 rounded-2xl border border-gray-200 dark:border-gray-700">
                    <h2 className="text-2xl font-bold text-text-primary mb-6">Get in Touch</h2>

                    <div className="flex items-start space-x-4">
                        <div className="text-primary-light mt-1">
                            <Mail className="w-6 h-6" />
                        </div>
                        <div>
                            <h3 className="font-semibold text-text-primary">Email</h3>
                            <p className="text-text-secondary mt-1">support@lifemonk.com</p>
                        </div>
                    </div>

                    <div className="flex items-start space-x-4">
                        <div className="p-3 bg-secondary-light/10 rounded-xl text-secondary-DEFAULT">
                            <Phone className="w-6 h-6" />
                        </div>
                        <div>
                            <h3 className="font-semibold text-text-primary">Phone</h3>
                            <p className="text-text-secondary mt-1">+91 98765 43210</p>
                            <p className="text-sm text-text-tertiary mt-1">Mon-Fri 9am-6pm IST</p>
                        </div>
                    </div>

                    <div className="flex items-start space-x-4">
                        <div className="p-3 bg-accent-light/10 rounded-xl text-accent-DEFAULT">
                            <MapPin className="w-6 h-6" />
                        </div>
                        <div>
                            <h3 className="font-semibold text-text-primary">Office</h3>
                            <p className="text-text-secondary mt-1">
                                Lifemonk Solutions,<br />
                                WeWork Embassy TechVillage,<br />
                                Outer Ring Road, Devarabisanahalli,<br />
                                Bengaluru, Karnataka, 560103, <br />
                                India.
                            </p>
                        </div>
                    </div>
                </div>

                {/* Contact Form */}
                <div className="bg-white/80 dark:bg-gray-900/80 p-8 rounded-2xl shadow-lg border border-gray-200 dark:border-gray-700">
                    <h2 className="text-2xl font-bold text-text-primary mb-6">Send us a Message</h2>
                    <form className="space-y-6">
                        <div>
                            <label htmlFor="name" className="block text-sm font-medium text-text-secondary mb-2">Name</label>
                            <input
                                type="text"
                                id="name"
                                className="w-full px-4 py-3 rounded-xl bg-background-light border border-slate-200 focus:border-primary-DEFAULT focus:ring-2 focus:ring-primary-light/20 outline-none transition-all"
                                placeholder="John Doe"
                            />
                        </div>
                        <div>
                            <label htmlFor="email" className="block text-sm font-medium text-text-secondary mb-2">Email</label>
                            <input
                                type="email"
                                id="email"
                                className="w-full px-4 py-3 rounded-xl bg-background-light border border-slate-200 focus:border-primary-DEFAULT focus:ring-2 focus:ring-primary-light/20 outline-none transition-all"
                                placeholder="john@example.com"
                            />
                        </div>
                        <div>
                            <label htmlFor="message" className="block text-sm font-medium text-text-secondary mb-2">Message</label>
                            <textarea
                                id="message"
                                rows="4"
                                className="w-full px-4 py-3 rounded-xl bg-background-light border border-slate-200 focus:border-primary-DEFAULT focus:ring-2 focus:ring-primary-light/20 outline-none transition-all resize-none"
                                placeholder="How can we help you?"
                            ></textarea>
                        </div>
                        <button className="w-full py-4 bg-primary-light hover:bg-primary-DEFAULT text-white rounded-xl font-semibold shadow-lg shadow-primary-light/30 transition-all transform hover:-translate-y-1">
                            Send Message
                        </button>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default Contact;

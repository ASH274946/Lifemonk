import React from 'react';
import { Link } from 'react-router-dom';

const About = () => {
    return (
        <section id="about" className="py-24 bg-background-white relative overflow-hidden">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="bg-primary-light/5 rounded-[3rem] p-8 md:p-16 relative">
                    {/* Decorative shapes */}
                    <div className="absolute top-0 right-0 w-64 h-64 bg-primary-light/10 dark:bg-primary-light/5 rounded-full mix-blend-multiply dark:mix-blend-screen filter blur-3xl opacity-70 animate-blob" />
                    <div className="absolute -bottom-8 left-20 w-72 h-72 bg-purple-300/10 dark:bg-purple-300/5 rounded-full mix-blend-multiply dark:mix-blend-screen filter blur-3xl opacity-70 animate-blob animation-delay-2000" />

                    <div className="relative z-10 grid lg:grid-cols-2 gap-12 items-center">
                        <div>
                            <h2 className="text-3xl md:text-4xl font-bold text-text-primary mb-6">
                                Our Mission is to Empower the Next Generation
                            </h2>
                            <div className="space-y-4 text-text-secondary text-lg">
                                <p>
                                    At Lifemonk, we believe education goes beyond textbooks. We're on a journey to build a platform that fosters creativity, critical thinking, and emotional intelligence.
                                </p>
                                <p>
                                    By combining modern technology with proven pedagogical methods, we've created a safe space where children love to learn and grow.
                                </p>
                            </div>
                            <Link to="/story" className="mt-8 text-primary-dark dark:text-primary-light font-bold hover:gap-3 transition-all flex items-center gap-2">
                                Read Our Story <span>→</span>
                            </Link>
                        </div>

                        <div className="relative group">
                            <div className="absolute -inset-2 bg-gradient-to-r from-primary-light to-blue-600 rounded-[2.5rem] blur opacity-30 group-hover:opacity-60 transition duration-500"></div>

                            {/* App Interface Mockup */}
                            <div className="relative aspect-video bg-white dark:bg-gray-900 rounded-[2rem] overflow-hidden shadow-2xl border-4 border-white dark:border-gray-800 flex flex-col">
                                {/* Header / fake browser bar */}
                                <div className="h-8 bg-gray-50 dark:bg-gray-800 border-b border-gray-100 dark:border-gray-700 flex items-center px-4 gap-2">
                                    <div className="flex gap-1.5">
                                        <div className="w-2.5 h-2.5 rounded-full bg-red-400"></div>
                                        <div className="w-2.5 h-2.5 rounded-full bg-yellow-400"></div>
                                        <div className="w-2.5 h-2.5 rounded-full bg-green-400"></div>
                                    </div>
                                    <div className="bg-white dark:bg-gray-900 rounded-md px-3 py-0.5 text-[10px] text-gray-400 flex-1 text-center font-medium mx-4">
                                        live.lifemonk.com/class/science-101
                                    </div>
                                </div>

                                {/* Main Content Area */}
                                <div className="flex-1 p-3 flex gap-3 overflow-hidden">
                                    {/* Main Video Feed (Teacher) */}
                                    <div className="flex-1 rounded-xl overflow-hidden relative group-hover:shadow-lg transition-all">
                                        <img
                                            src="https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&auto=format&fit=crop&q=80"
                                            alt="Teacher"
                                            className="w-full h-full object-cover"
                                        />
                                        <div className="absolute top-3 left-3 bg-red-500 text-white text-[10px] font-bold px-2 py-1 rounded-md animate-pulse">
                                            LIVE
                                        </div>
                                        <div className="absolute bottom-3 left-3 bg-black/40 backdrop-blur-md text-white text-xs px-2 py-1 rounded-lg">
                                            Ms. Sarah - Science 🧬
                                        </div>
                                    </div>

                                    {/* Sidebar (Students/Chat) */}
                                    <div className="w-1/4 flex flex-col gap-2">
                                        <div className="bg-gray-50 dark:bg-gray-800 p-2 rounded-xl flex-1 flex flex-col gap-2">
                                            <div className="text-[10px] font-bold text-gray-400 uppercase">Classmates</div>
                                            {[1, 2, 3].map((i) => (
                                                <div key={i} className="flex items-center gap-2">
                                                    <img
                                                        src={`https://api.dicebear.com/9.x/notionists/svg?seed=${i}`}
                                                        alt="Student"
                                                        className="w-6 h-6 rounded-full bg-white border border-gray-200"
                                                    />
                                                    <div className="h-1.5 w-12 bg-gray-200 dark:bg-gray-700 rounded-full"></div>
                                                </div>
                                            ))}
                                        </div>
                                        <div className="bg-blue-50 dark:bg-blue-900/20 p-2 rounded-xl h-12 flex items-center justify-center">
                                            <div className="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center text-white text-xs">
                                                ✋
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    );
};

export default About;

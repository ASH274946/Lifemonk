import React from 'react';
import { motion } from 'framer-motion';
import { PlayCircle, ArrowRight, Sparkles } from 'lucide-react';

const Hero = () => {
    return (
        <section id="home" className="relative pt-32 pb-20 lg:pt-40 lg:pb-32 overflow-hidden">
            {/* Background Decorative Elements */}
            <div className="absolute top-0 right-0 -mr-20 -mt-20 w-[600px] h-[600px] bg-primary-light/10 rounded-full blur-3xl" />
            <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-[400px] h-[400px] bg-sky-200/20 rounded-full blur-3xl" />

            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                <div className="grid lg:grid-cols-2 gap-12 lg:gap-8 items-center">
                    {/* Text Content */}
                    <motion.div
                        initial={{ opacity: 0, x: -50 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ duration: 0.8, ease: "easeOut" }}
                    >
                        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary-light/10 text-primary-dark font-medium text-sm mb-6">
                            <Sparkles size={16} />
                            <span>Learning Reimagined for Kids</span>
                        </div>

                        <h1 className="text-5xl lg:text-7xl font-bold text-text-primary leading-tight mb-6">
                            Grow Smarter, <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary-light to-primary-dark">
                                Live Happier.
                            </span>
                        </h1>

                        <p className="text-lg text-text-secondary mb-8 leading-relaxed max-w-lg">
                            Lifemonk combines interactive courses, mindfulness, and fun challenges to help children develop essential life skills in a gamified world.
                        </p>

                        <div className="flex flex-col sm:flex-row gap-4">
                            <a
                                href="/lifemonk.apk"
                                download="lifemonk.apk"
                                className="bg-primary-light text-white px-8 py-4 rounded-2xl font-bold text-lg shadow-xl shadow-primary-light/30 hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 flex items-center justify-center gap-2"
                            >
                                Start Learning Now
                                <ArrowRight size={20} />
                            </a>

                            <button className="bg-white text-gray-900 px-8 py-4 rounded-2xl font-bold text-lg border-2 border-gray-100 dark:border-gray-700 hover:border-primary-light/30 hover:bg-gray-50 transition-all duration-300 flex items-center justify-center gap-2">
                                <PlayCircle size={20} className="text-primary-light" />
                                Watch Demo
                            </button>
                        </div>

                        <div className="mt-12 flex items-center gap-4 text-sm text-text-secondary font-medium">
                            <div className="flex -space-x-3">
                                {['Felix', 'Bubba', 'Morph', 'Destiny'].map((seed, i) => (
                                    <div key={i} className="w-10 h-10 rounded-full border-2 border-white dark:border-gray-800 bg-gray-200 overflow-hidden">
                                        <img
                                            src={`https://api.dicebear.com/9.x/adventurer/svg?seed=${seed}`}
                                            alt="User Avatar"
                                            className="w-full h-full object-cover"
                                        />
                                    </div>
                                ))}
                            </div>
                            <p>Trusted by <span className="text-primary-dark dark:text-primary-light font-bold">10,000+</span> parents & schools</p>
                        </div>
                    </motion.div>

                    {/* Visual Content (Mockup/Illustration) */}
                    <motion.div
                        initial={{ opacity: 0, scale: 0.8 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ duration: 0.8, delay: 0.2 }}
                        className="relative"
                    >
                        <div className="relative mx-auto w-full max-w-[400px] lg:max-w-[450px]">
                            {/* Abstract decorative circle */}
                            <div className="absolute inset-0 bg-gradient-to-tr from-primary-light to-blue-600 rounded-full opacity-20 blur-3xl transform rotate-6 scale-110" />

                            {/* "Glass" Card representing the app interface */}
                            <div className="relative glass-card rounded-[2.5rem] p-6 border-4 border-white dark:border-gray-700 overflow-hidden shadow-2xl rotate-[-3deg] hover:rotate-0 transition-transform duration-500 bg-white/90 dark:bg-gray-900/90 backdrop-blur">
                                {/* Mock UI Header */}
                                <div className="flex justify-between items-center mb-6">
                                    <div className="flex items-center gap-3">
                                        <div className="w-10 h-10 rounded-full bg-orange-100 flex items-center justify-center overflow-hidden border-2 border-white">
                                            <img src="https://api.dicebear.com/9.x/adventurer/svg?seed=Alex" alt="Profile" />
                                        </div>
                                        <div>
                                            <div className="h-2 w-20 bg-gray-200 dark:bg-gray-700 rounded-full mb-1" />
                                            <div className="h-3 w-24 bg-gray-800 dark:bg-gray-200 rounded-full" />
                                        </div>
                                    </div>
                                    <div className="p-2 bg-gray-50 dark:bg-gray-800 rounded-xl">
                                        <div className="w-5 h-5 border-2 border-gray-300 dark:border-gray-600 rounded-full" />
                                    </div>
                                </div>

                                {/* Mock UI Content */}
                                <div className="space-y-4">
                                    {/* Main Progress Card */}
                                    <div className="bg-gradient-to-r from-indigo-500 to-purple-600 p-5 rounded-3xl text-white relative overflow-hidden">
                                        <div className="absolute top-0 right-0 w-24 h-24 bg-white/10 rounded-full -mr-10 -mt-10 blur-xl" />
                                        <p className="text-indigo-100 text-xs font-semibold mb-1 uppercase tracking-wider">Current Lesson</p>
                                        <h3 className="font-bold text-lg mb-3">Space Adventure 🚀</h3>

                                        <div className="flex items-center gap-3 text-xs font-medium mb-1">
                                            <span>Progress</span>
                                            <span className="opacity-80">65%</span>
                                        </div>
                                        <div className="h-2 bg-black/20 rounded-full overflow-hidden">
                                            <div className="h-full bg-white/90 w-[65%] rounded-full" />
                                        </div>
                                    </div>

                                    {/* Action Grid */}
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="bg-orange-50 dark:bg-orange-900/20 p-4 rounded-2xl">
                                            <div className="w-8 h-8 bg-orange-100 dark:bg-orange-800 text-orange-600 dark:text-orange-400 rounded-lg flex items-center justify-center mb-3">
                                                <span className="font-bold text-lg">Aa</span>
                                            </div>
                                            <div className="h-2 w-16 bg-orange-200 dark:bg-orange-800/50 rounded-full mb-2" />
                                            <div className="h-2 w-10 bg-orange-100 dark:bg-orange-900/50 rounded-full" />
                                        </div>
                                        <div className="bg-teal-50 dark:bg-teal-900/20 p-4 rounded-2xl">
                                            <div className="w-8 h-8 bg-teal-100 dark:bg-teal-800 text-teal-600 dark:text-teal-400 rounded-lg flex items-center justify-center mb-3">
                                                <span className="font-bold text-lg">123</span>
                                            </div>
                                            <div className="h-2 w-16 bg-teal-200 dark:bg-teal-800/50 rounded-full mb-2" />
                                            <div className="h-2 w-10 bg-teal-100 dark:bg-teal-900/50 rounded-full" />
                                        </div>
                                    </div>
                                </div>

                                {/* Floating Elements */}
                                <motion.div
                                    animate={{ y: [0, -10, 0] }}
                                    transition={{ repeat: Infinity, duration: 3, ease: "easeInOut" }}
                                    className="absolute top-1/3 -right-6 bg-white dark:bg-gray-800 p-3 rounded-2xl shadow-xl flex items-center gap-3 z-20 border border-gray-100 dark:border-gray-700"
                                >
                                    <div className="bg-green-100 dark:bg-green-900/50 p-2 rounded-full text-green-600 dark:text-green-400">
                                        <Sparkles size={16} />
                                    </div>
                                    <div>
                                        <p className="text-[10px] text-gray-400 font-medium uppercase">Streak</p>
                                        <p className="text-sm font-bold text-gray-800 dark:text-white">12 Days 🔥</p>
                                    </div>
                                </motion.div>
                            </div>
                        </div>
                    </motion.div>
                </div>
            </div>
        </section>
    );
};

export default Hero;

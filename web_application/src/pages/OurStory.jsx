import React from 'react';
import { Heart, Target, Users, Lightbulb, ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

const OurStory = () => {
    const values = [
        {
            icon: Heart,
            title: 'Passion for Learning',
            description: 'We believe every child deserves access to joyful, engaging education that sparks curiosity.',
        },
        {
            icon: Target,
            title: 'Purpose-Driven',
            description: 'Our mission guides every decision—empowering the next generation to thrive.',
        },
        {
            icon: Users,
            title: 'Community First',
            description: 'We build together with parents, teachers, and children at the heart of everything.',
        },
        {
            icon: Lightbulb,
            title: 'Innovation',
            description: 'We blend cutting-edge technology with proven pedagogical methods.',
        },
    ];

    const timeline = [
        { year: '2023', title: 'The Spark', description: 'Founded with a vision to transform childhood education through technology.' },
        { year: '2024', title: 'First Launch', description: 'Released our mobile app with core learning modules and vocabulary tools.' },
        { year: '2025', title: 'Growing Community', description: 'Reached 100,000+ active learners and partnered with 50+ schools.' },
        { year: '2026', title: 'The Future', description: 'Expanding globally with AI-powered personalized learning paths.' },
    ];

    return (
        <div className="pt-32 pb-20">
            {/* Hero Section */}
            <div className="max-w-7xl mx-auto px-4 md:px-8 mb-20">
                <div className="text-center mb-16">
                    <h1 className="text-5xl md:text-6xl font-bold text-text-primary mb-6">
                        Our Story
                    </h1>
                    <p className="text-xl text-text-secondary max-w-3xl mx-auto">
                        At Lifemonk, we believe education goes beyond textbooks. We're on a journey to build a platform that fosters creativity, critical thinking, and emotional intelligence.
                    </p>
                </div>

                {/* Mission Statement */}
                <div className="bg-gradient-to-br from-primary-light to-blue-600 rounded-3xl p-12 text-white text-center mb-20">
                    <h2 className="text-3xl md:text-4xl font-bold mb-4">Our Mission</h2>
                    <p className="text-xl opacity-90 max-w-2xl mx-auto">
                        To empower every child with the skills, confidence, and curiosity they need to succeed in life—not just in school.
                    </p>
                </div>

                {/* The Beginning */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center mb-20">
                    <div>
                        <h2 className="text-3xl font-bold text-text-primary mb-6">How It All Started</h2>
                        <p className="text-text-secondary mb-4">
                            Lifemonk was born from a simple observation: traditional education often fails to engage children's natural curiosity. We saw kids who loved learning through games and videos struggle with conventional methods.
                        </p>
                        <p className="text-text-secondary mb-4">
                            Our founders—educators, technologists, and parents—came together with a shared vision: What if we could make learning feel like play? What if every child could discover their potential through experiences that excite them?
                        </p>
                        <p className="text-text-secondary">
                            By combining modern technology with proven pedagogical methods, we've created a safe space where children love to learn and grow. Every feature, every lesson, every interaction is designed with one goal: helping kids become the best version of themselves.
                        </p>
                    </div>
                    <div className="bg-gray-100 dark:bg-gray-800 rounded-3xl aspect-square flex items-center justify-center">
                        <img
                            src="https://images.unsplash.com/photo-1577896851231-70ef18881754?w=600"
                            alt="Children learning together"
                            className="rounded-3xl object-cover w-full h-full"
                        />
                    </div>
                </div>

                {/* Timeline */}
                <div className="mb-20">
                    <h2 className="text-3xl font-bold text-text-primary text-center mb-12">Our Journey</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                        {timeline.map((item, index) => (
                            <div key={index} className="relative">
                                <div className="bg-white dark:bg-gray-900 p-6 rounded-2xl border border-gray-200 dark:border-gray-700 h-full">
                                    <span className="text-4xl font-bold text-primary-light">{item.year}</span>
                                    <h3 className="text-xl font-bold text-text-primary mt-2 mb-2">{item.title}</h3>
                                    <p className="text-text-secondary text-sm">{item.description}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Values */}
                <div className="mb-20">
                    <h2 className="text-3xl font-bold text-text-primary text-center mb-12">Our Values</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                        {values.map((value, index) => {
                            const Icon = value.icon;
                            return (
                                <div key={index} className="text-center p-6 bg-white dark:bg-gray-900 rounded-2xl border border-gray-200 dark:border-gray-700">
                                    <div className="w-14 h-14 bg-primary-light/10 rounded-xl flex items-center justify-center mx-auto mb-4">
                                        <Icon className="w-7 h-7 text-primary-light" />
                                    </div>
                                    <h3 className="text-lg font-bold text-text-primary mb-2">{value.title}</h3>
                                    <p className="text-text-secondary text-sm">{value.description}</p>
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* CTA */}
                <div className="text-center bg-gray-100 dark:bg-gray-800 rounded-3xl p-12">
                    <h2 className="text-3xl font-bold text-text-primary mb-4">Join Our Mission</h2>
                    <p className="text-text-secondary mb-8 max-w-xl mx-auto">
                        Whether you're a parent, teacher, or just someone who believes in better education—we'd love to have you on this journey.
                    </p>
                    <div className="flex flex-col sm:flex-row gap-4 justify-center">
                        <Link
                            to="/contact"
                            className="py-3 px-8 bg-primary-light text-white rounded-xl font-semibold hover:bg-primary-DEFAULT transition-colors shadow-lg"
                        >
                            Get in Touch
                        </Link>
                        <Link
                            to="/schools"
                            className="py-3 px-8 bg-white dark:bg-gray-900 text-text-primary rounded-xl font-semibold border border-gray-200 dark:border-gray-700 hover:border-primary-light transition-colors"
                        >
                            Partner With Us
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default OurStory;

import React from 'react';
import { Check, Users, Award, BookOpen, Headphones, TrendingUp } from 'lucide-react';
import { Link } from 'react-router-dom';

const Schools = () => {
    const benefits = [
        {
            icon: Users,
            title: 'Unlimited Student Accounts',
            description: 'Add as many students as you need without per-seat pricing.',
        },
        {
            icon: Award,
            title: 'Teacher Dashboard',
            description: 'Monitor progress, assign tasks, and track performance in real-time.',
        },
        {
            icon: BookOpen,
            title: 'Custom Curriculum',
            description: 'Align content with your school\'s educational standards and goals.',
        },
        {
            icon: Headphones,
            title: 'Dedicated Support',
            description: 'Priority onboarding, training, and ongoing technical assistance.',
        },
        {
            icon: TrendingUp,
            title: 'Analytics & Reporting',
            description: 'Comprehensive insights into student engagement and learning outcomes.',
        },
    ];

    const features = [
        'Bulk licensing with special pricing',
        'Single Sign-On (SSO) integration',
        'Custom branding options',
        'Parent communication portal',
        'Offline mode for low-connectivity areas',
        'FERPA & COPPA compliant',
        'Professional development for teachers',
        'Implementation roadmap & training',
    ];

    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-7xl mx-auto">
            {/* Hero Section */}
            <div className="text-center mb-20">
                <h1 className="text-5xl md:text-6xl font-bold text-text-primary mb-6">
                    Lifemonk for Schools
                </h1>
                <p className="text-xl text-text-secondary max-w-3xl mx-auto mb-8">
                    Empower your entire school with engaging, research-backed learning experiences.
                    Built for educators, loved by students.
                </p>
                <Link
                    to="/contact"
                    className="inline-block py-4 px-8 bg-primary-light text-white rounded-xl font-semibold hover:bg-primary-DEFAULT transition-colors shadow-lg shadow-primary-light/30"
                >
                    Schedule a Demo
                </Link>
            </div>

            {/* Benefits Grid */}
            <div className="mb-20">
                <h2 className="text-3xl font-bold text-text-primary text-center mb-12">
                    Why Schools Choose Lifemonk
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {benefits.map((benefit, index) => {
                        const Icon = benefit.icon;
                        return (
                            <div
                                key={index}
                                className="p-6 bg-white/50 dark:bg-gray-900/50 rounded-2xl border border-white/20 hover:bg-white/80 dark:hover:bg-gray-800/80 transition-all"
                            >
                                <div className="w-12 h-12 bg-primary-light/10 rounded-xl flex items-center justify-center mb-4">
                                    <Icon className="w-6 h-6 text-primary-DEFAULT" />
                                </div>
                                <h3 className="text-xl font-bold text-text-primary mb-2">{benefit.title}</h3>
                                <p className="text-text-secondary">{benefit.description}</p>
                            </div>
                        );
                    })}
                </div>
            </div>

            {/* Features List */}
            <div className="bg-gradient-to-br from-primary-light/5 to-secondary-light/5 rounded-3xl p-12 mb-20">
                <h2 className="text-3xl font-bold text-text-primary text-center mb-12">
                    Everything Your School Needs
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-4xl mx-auto">
                    {features.map((feature, index) => (
                        <div key={index} className="flex items-center">
                            <Check className="w-5 h-5 text-primary-DEFAULT mr-3 flex-shrink-0" />
                            <span className="text-text-secondary">{feature}</span>
                        </div>
                    ))}
                </div>
            </div>

            {/* CTA Section */}
            <div className="text-center bg-primary-light text-white rounded-3xl p-12">
                <h2 className="text-3xl font-bold mb-4">Ready to Transform Your School?</h2>
                <p className="text-lg mb-8 opacity-90">
                    Join hundreds of schools already using Lifemonk to engage and inspire students.
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <Link
                        to="/contact"
                        className="py-3 px-8 bg-white text-primary-light rounded-xl font-semibold hover:bg-gray-100 transition-colors shadow-lg"
                    >
                        Request a Quote
                    </Link>
                    <Link
                        to="/pricing"
                        className="py-3 px-8 bg-primary-dark text-white rounded-xl font-semibold hover:bg-primary-dark/80 transition-colors"
                    >
                        View Pricing
                    </Link>
                </div>
            </div>
        </div>
    );
};

export default Schools;

import React from 'react';
import { BookOpen, Play, Mic, Wind, Users, Award } from 'lucide-react';

const FeatureCard = ({ icon: Icon, title, description, color }) => (
    <div className="bg-background-white dark:bg-background-white/5 rounded-[2rem] p-8 border border-gray-100 dark:border-gray-800 hover:shadow-xl hover:shadow-gray-200/50 dark:hover:shadow-none hover:-translate-y-2 transition-all duration-300 group">
        <div className={`w-14 h-14 rounded-2xl ${color} flex items-center justify-center mb-6 group-hover:scale-110 transition-transform`}>
            <Icon size={28} className="text-white" />
        </div>
        <h3 className="text-xl font-bold text-text-primary mb-3">{title}</h3>
        <p className="text-text-secondary leading-relaxed">{description}</p>
    </div>
);

const Features = () => {
    const features = [
        {
            icon: BookOpen,
            title: "Interactive Courses",
            description: "Step-by-step learning modules designed to cover academic and life skills in an engaging way.",
            color: "bg-blue-500",
        },
        {
            icon: Play,
            title: "Ed-Bytes",
            description: "Short, snackable video lessons that make complex topics easy to understand and remember.",
            color: "bg-red-500",
        },
        {
            icon: Mic,
            title: "Vocabulary Builder",
            description: "Master new words with our AI-powered pronunciation coach and fun flashcards.",
            color: "bg-yellow-500",
        },
        {
            icon: Wind,
            title: "Mindfulness",
            description: "Guided breathing exercises and meditation to help kids stay calm, focused, and happy.",
            color: "bg-teal-500",
        },
        {
            icon: Users,
            title: "Live Workshops",
            description: "Join interactive sessions with experts and peers to learn together in real-time.",
            color: "bg-purple-500",
        },
        {
            icon: Award,
            title: "Gamified Progress",
            description: "Earn badges, streaks, and rewards as you learn, keeping motivation high every day.",
            color: "bg-orange-500",
        },
    ];

    return (
        <section id="features" className="py-24 bg-background-gray">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="text-center max-w-3xl mx-auto mb-16">
                    <span className="text-primary-DEFAULT font-semibold tracking-wider uppercase text-sm">Everything you need</span>
                    <h2 className="text-4xl font-bold text-text-primary mt-3 mb-6">Unlocking Potential in Every Child</h2>
                    <p className="text-text-secondary text-lg">
                        Lifemonk is more than just an app; it's a holistic ecosystem designed to nurture intellectual curiosity and emotional well-being.
                    </p>
                </div>

                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {features.map((feature, index) => (
                        <FeatureCard key={index} {...feature} />
                    ))}
                </div>
            </div>
        </section>
    );
};

export default Features;

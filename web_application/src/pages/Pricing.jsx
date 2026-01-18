import React from 'react';
import { Check, Star } from 'lucide-react';
import { Link } from 'react-router-dom';

const Pricing = () => {
    const plans = [
        {
            name: 'Explorer',
            price: 'Free',
            period: 'forever',
            description: 'Perfect for trying out Lifemonk and learning the basics.',
            features: [
                'Access to 5 intro courses',
                'Daily "Byte" video',
                'Basic vocabulary tools',
                'Community access',
            ],
            cta: 'Start Free',
            popular: false,
        },
        {
            name: 'Scholar',
            price: '$9.99',
            period: '/month',
            description: 'Unlock the full potential of your learning journey.',
            features: [
                'Unlimited access to all courses',
                'Unlimited "Bytes"',
                'Advanced pronunciation tools',
                'Progress tracking & analytics',
                'Offline mode',
                'Priority support',
            ],
            cta: 'Go Premium',
            popular: true,
        },
        {
            name: 'Family',
            price: '$19.99',
            period: '/month',
            description: 'The best value for families with up to 4 kids.',
            features: [
                'Everything in Scholar',
                'Up to 4 child profiles',
                'Parental control dashboard',
                'Family challenges & quests',
                'Dedicated success coach',
            ],
            cta: 'Get Family Plan',
            popular: false,
        },
    ];

    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-7xl mx-auto">
            <div className="text-center mb-16">
                <h1 className="text-4xl md:text-5xl font-bold text-text-primary mb-4">
                    Simple, Transparent Pricing
                </h1>
                <p className="text-xl text-text-secondary max-w-2xl mx-auto">
                    Invest in your child's future with a plan that grows with them. No hidden fees, cancel anytime.
                </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {plans.map((plan, index) => (
                    <div
                        key={index}
                        className={`relative p-8 rounded-3xl border transition-all duration-300 hover:-translate-y-2 ${plan.popular
                                ? 'bg-white/80 dark:bg-gray-800/80 border-primary-light shadow-xl ring-4 ring-primary-light/10'
                                : 'bg-white/50 dark:bg-gray-900/50 border-white/20 hover:bg-white/80 dark:hover:bg-gray-800/80 shadow-lg'
                            }`}
                    >
                        {plan.popular && (
                            <div className="absolute -top-4 left-1/2 -translate-x-1/2 px-4 py-1 bg-primary-DEFAULT text-white text-sm font-semibold rounded-full shadow-lg">
                                Most Popular
                            </div>
                        )}

                        <h3 className="text-2xl font-bold text-text-primary mb-2">{plan.name}</h3>
                        <div className="flex items-baseline mb-4">
                            <span className="text-4xl font-bold text-text-primary">{plan.price}</span>
                            <span className="text-text-secondary ml-1">{plan.period}</span>
                        </div>
                        <p className="text-text-secondary mb-8 h-12">{plan.description}</p>

                        <Link
                            to="/get-started"
                            className={`block w-full py-3 px-6 rounded-xl font-semibold text-center transition-colors ${plan.popular
                                    ? 'bg-primary-DEFAULT text-white hover:bg-primary-dark shadow-lg shadow-primary-light/30'
                                    : 'bg-white dark:bg-gray-800 text-text-primary border border-gray-200 dark:border-gray-700 hover:border-primary-light hover:text-primary-DEFAULT'
                                }`}
                        >
                            {plan.cta}
                        </Link>

                        <ul className="mt-8 space-y-4">
                            {plan.features.map((feature, i) => (
                                <li key={i} className="flex items-start">
                                    <Check className={`w-5 h-5 mr-3 flex-shrink-0 ${plan.popular ? 'text-primary-DEFAULT' : 'text-text-secondary'}`} />
                                    <span className="text-text-secondary">{feature}</span>
                                </li>
                            ))}
                        </ul>
                    </div>
                ))}
            </div>

            <div className="mt-20 text-center bg-accent-light/10 rounded-3xl p-12 max-w-4xl mx-auto">
                <h2 className="text-3xl font-bold text-text-primary mb-4">Need a custom plan for your school?</h2>
                <p className="text-text-secondary mb-8">
                    We offer special bulk pricing and implementation support for educational institutions.
                </p>
                <Link
                    to="/contact"
                    className="inline-block py-3 px-8 bg-accent-DEFAULT text-white rounded-xl font-semibold hover:bg-accent-dark transition-colors shadow-lg shadow-accent-light/30"
                >
                    Contact Sales
                </Link>
            </div>
        </div>
    );
};

export default Pricing;

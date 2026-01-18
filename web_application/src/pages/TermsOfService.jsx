import React from 'react';

const TermsOfService = () => {
    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-4xl mx-auto">
            <h1 className="text-4xl font-bold text-text-primary mb-8">Terms of Service</h1>
            <div className="prose prose-lg text-text-secondary">
                <p className="mb-4">Last updated: January 18, 2026</p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">1. Acceptance of Terms</h2>
                <p>
                    By accessing or using our services, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">2. User Accounts</h2>
                <p>
                    You are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">3. Restrictions</h2>
                <p>
                    You may not use the service for any illegal purpose or in any manner inconsistent with these Terms.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">4. Termination</h2>
                <p>
                    We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever.
                </p>
            </div>
        </div>
    );
};

export default TermsOfService;

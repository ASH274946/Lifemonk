import React from 'react';

const PrivacyPolicy = () => {
    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-4xl mx-auto">
            <h1 className="text-4xl font-bold text-text-primary mb-8">Privacy Policy</h1>
            <div className="prose prose-lg text-text-secondary">
                <p className="mb-4">Last updated: January 18, 2026</p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">1. Introduction</h2>
                <p>
                    Welcome to Lifemonk ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience on our website and with our products and services.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">2. Information We Collect</h2>
                <p>
                    We collect information that you strictly provide to us, such as your name, email address, and phone number when you register for an account or contact us.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">3. Check for Updates</h2>
                <p>
                    We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">4. Contact Us</h2>
                <p>
                    If you have any questions about this Privacy Policy, please contact us at support@lifemonk.com.
                </p>
            </div>
        </div>
    );
};

export default PrivacyPolicy;

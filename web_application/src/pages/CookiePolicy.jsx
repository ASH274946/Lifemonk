import React from 'react';

const CookiePolicy = () => {
    return (
        <div className="pt-32 pb-20 px-4 md:px-8 max-w-4xl mx-auto">
            <h1 className="text-4xl font-bold text-text-primary mb-8">Cookie Policy</h1>
            <div className="prose prose-lg text-text-secondary">
                <p className="mb-4">Last updated: January 18, 2026</p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">1. What Are Cookies</h2>
                <p>
                    Cookies are small pieces of text sent to your web browser by a website you visit. A cookie file is stored in your web browser and allows the Service or a third-party to recognize you and make your next visit easier and the Service more useful to you.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">2. How We Use Cookies</h2>
                <p>
                    We use cookies for the following purposes: to enable certain functions of the Service, to provide analytics, to store your preferences, and to enable advertisements delivery, including behavioral advertising.
                </p>

                <h2 className="text-2xl font-bold text-text-primary mt-8 mb-4">3. Your Choices</h2>
                <p>
                    If you'd like to delete cookies or instruct your web browser to delete or refuse cookies, please visit the help pages of your web browser.
                </p>
            </div>
        </div>
    );
};

export default CookiePolicy;

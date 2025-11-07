const roadmaps = {
    java: {
        title: "Java Full Stack Roadmap",
        steps: [
            "Learn Core Java (OOPs, Collections, Exception Handling)",
            "Master SQL & Databases (MySQL, PostgreSQL)",
            "Frontend Basics: HTML, CSS, JavaScript",
            "Frameworks: Spring Boot, Hibernate, REST APIs",
            "Frontend Frameworks: React or Angular",
            "Version Control: Git & GitHub",
            "Build Tools: Maven or Gradle",
            "Deployment: Docker, Jenkins CI/CD pipeline"
        ]
    },
    aiml: {
        title: "AI / ML Roadmap",
        steps: [
            "Learn Python fundamentals and libraries (NumPy, Pandas)",
            "Understand Math for ML (Linear Algebra, Statistics)",
            "Study ML algorithms (Regression, SVM, Decision Trees)",
            "Deep Learning frameworks (TensorFlow, PyTorch)",
            "Work on real datasets (Kaggle, UCI ML Repo)",
            "Model deployment using Flask or FastAPI",
            "Integrate ML models into applications"
        ]
    },
    devops: {
        title: "DevOps Roadmap",
        steps: [
            "Learn Linux and Shell Scripting",
            "Understand Networking & Cloud basics (AWS, Azure, GCP)",
            "Version Control using Git & GitHub",
            "Build Tools: Maven, Gradle",
            "CI/CD using Jenkins",
            "Containerization with Docker",
            "Orchestration using Kubernetes",
            "Monitoring and Logging (Prometheus, Grafana, ELK Stack)"
        ]
    }
};

function showRoadmap(topic) {
    const roadmap = roadmaps[topic];
    document.getElementById('roadmap-title').textContent = roadmap.title;

    const list = document.getElementById('roadmap-content');
    list.innerHTML = "";
    roadmap.steps.forEach(step => {
        const li = document.createElement('li');
        li.textContent = step;
        list.appendChild(li);
    });

    document.getElementById('roadmap-section').scrollIntoView({ behavior: 'smooth' });
}
